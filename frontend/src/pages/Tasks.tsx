import { useState, useMemo } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { DragDropContext, Droppable, Draggable, type DropResult } from "@hello-pangea/dnd";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import { useProject } from "../hooks/useProject";
import { useToast } from "../context/useToast";
import EditTaskModal from "../components/EditTaskModel";
import type { Task, TaskPriority, TaskStatus } from "../types/Task";
import type { Sprint } from "../types/Sprint";
import type { TeamMember } from "../types/TeamMember";

type TaskViewMode = "board" | "list" | "calendar";

interface TaskColumns {
  TODO: Task[];
  IN_PROGRESS: Task[];
  REVIEW: Task[];
  BLOCKED: Task[];
  DONE: Task[];
}

export default function Tasks() {
  const { projectId } = useParams<{ projectId: string }>();
  const navigate = useNavigate();
  const { showToast } = useToast();
  const queryClient = useQueryClient();

  const [viewMode, setViewMode] = useState<TaskViewMode>("board");
  const [showBacklog, setShowBacklog] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");

  // Create Task Form State
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [createTitle, setCreateTitle] = useState("");
  const [createDesc, setCreateDesc] = useState("");
  const [createStatus, setCreateStatus] = useState<TaskStatus>("TODO");
  const [createPriority, setCreatePriority] = useState<TaskPriority>("LOW");
  const [createPoints, setCreatePoints] = useState(0);
  const [createSprintId, setCreateSprintId] = useState("");
  const [createAssigneeId, setCreateAssigneeId] = useState("");
  const [createIsBacklog, setCreateIsBacklog] = useState(false);

  // Edit Task State
  const [activeEditTask, setActiveEditTask] = useState<Task | null>(null);

  // Optimistic Board drag drop state
  const [optimisticBoard, setOptimisticBoard] = useState<TaskColumns | null>(null);

  // Calendar current Date state
  const [calendarDate, setCalendarDate] = useState(new Date());

  // 1. Fetch project details
  const { data: project, isLoading: projectLoading } = useProject(projectId as string);
  const teamId = project?.teamId || "";

  // 2. Fetch project tasks
  const { data: serverTasks = [], isLoading: tasksLoading } = useQuery<Task[]>({
    queryKey: ["tasks", projectId],
    queryFn: async () => {
      const res = await api.get(`/tasks/project/${projectId}`);
      return res.data?.data ?? [];
    },
    enabled: !!projectId,
  });

  // 3. Fetch team members
  const { data: members = [] } = useQuery<TeamMember[]>({
    queryKey: ["team-members", teamId],
    queryFn: async () => {
      const res = await api.get(`/teams/${teamId}/members`);
      return res.data?.data ?? [];
    },
    enabled: !!teamId,
  });

  // 4. Fetch sprints
  const { data: sprints = [] } = useQuery<Sprint[]>({
    queryKey: ["team-sprints", teamId],
    queryFn: async () => {
      const res = await api.get("/sprints", {
        params: { teamId, workspaceId: project?.team?.workspaceId },
      });
      return res.data?.data ?? [];
    },
    enabled: !!teamId && !!project?.team?.workspaceId,
  });

  // Create Task Mutation
  const createTaskMutation = useMutation({
    mutationFn: async () => {
      await api.post("/tasks", {
        title: createTitle,
        description: createDesc || null,
        status: createStatus,
        priority: createPriority,
        storyPoints: createPoints || null,
        sprintId: createSprintId || null,
        assignedToId: createAssigneeId || null,
        projectId,
        isBacklog: createIsBacklog,
      });
    },
    onSuccess: () => {
      showToast("Task created successfully!", "success");
      setCreateTitle("");
      setCreateDesc("");
      setCreateStatus("TODO");
      setCreatePriority("LOW");
      setCreatePoints(0);
      setCreateSprintId("");
      setCreateAssigneeId("");
      setCreateIsBacklog(false);
      setShowCreateModal(false);
      queryClient.invalidateQueries({ queryKey: ["tasks", projectId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to create task", "error");
    },
  });

  // Drag Drop Update Mutation
  const dragUpdateMutation = useMutation({
    mutationFn: async ({ taskId, newStatus }: { taskId: string; newStatus: TaskStatus }) => {
      await api.patch(`/tasks/${taskId}`, { status: newStatus });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["tasks", projectId] });
      setOptimisticBoard(null);
    },
    onError: () => {
      showToast("Failed to sync card movement, reverting", "error");
      setOptimisticBoard(null);
    },
  });

  // Delete Task Mutation
  const deleteTaskMutation = useMutation({
    mutationFn: async (id: string) => {
      await api.delete(`/tasks/${id}`);
    },
    onSuccess: () => {
      showToast("Task deleted successfully", "success");
      queryClient.invalidateQueries({ queryKey: ["tasks", projectId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to delete task", "error");
    },
  });

  // Filter tasks based on Search query and Backlog filter
  const filteredTasks = useMemo(() => {
    return serverTasks.filter((t) => {
      // 1. Backlog filter
      if (!showBacklog && t.isBacklog) return false;
      // 2. Search query filter
      if (searchQuery.trim()) {
        const query = searchQuery.toLowerCase();
        const matchesTitle = t.title.toLowerCase().includes(query);
        const matchesDesc = t.description?.toLowerCase().includes(query) ?? false;
        return matchesTitle || matchesDesc;
      }
      return true;
    });
  }, [serverTasks, showBacklog, searchQuery]);

  // Construct Board Columns structure
  const boardColumns: TaskColumns = useMemo(() => {
    return {
      TODO: filteredTasks.filter((t) => t.status === "TODO"),
      IN_PROGRESS: filteredTasks.filter((t) => t.status === "IN_PROGRESS"),
      REVIEW: filteredTasks.filter((t) => t.status === "REVIEW"),
      BLOCKED: filteredTasks.filter((t) => t.status === "BLOCKED"),
      DONE: filteredTasks.filter((t) => t.status === "DONE"),
    };
  }, [filteredTasks]);

  const activeBoard = optimisticBoard || boardColumns;

  // Drag and Drop Handler
  const handleDragEnd = (result: DropResult) => {
    const { destination, source, draggableId } = result;
    if (!destination) return;
    if (destination.droppableId === source.droppableId && destination.index === source.index) return;

    const sourceStatus = source.droppableId as TaskStatus;
    const destStatus = destination.droppableId as TaskStatus;

    // Apply Optimistic update locally
    const newBoard = structuredClone(activeBoard);
    const [movedTask] = newBoard[sourceStatus].splice(source.index, 1);
    movedTask.status = destStatus;
    newBoard[destStatus].splice(destination.index, 0, movedTask);

    setOptimisticBoard(newBoard);

    // Call API patch
    dragUpdateMutation.mutate({ taskId: draggableId, newStatus: destStatus });
  };

  // Helper Calendar Months Generator
  const getDaysInMonth = (date: Date) => {
    const year = date.getFullYear();
    const month = date.getMonth();
    const firstDay = new Date(year, month, 1).getDay();
    const totalDays = new Date(year, month + 1, 0).getDate();

    const days = [];
    for (let i = 0; i < firstDay; i++) days.push(null);
    for (let d = 1; d <= totalDays; d++) days.push(new Date(year, month, d));
    return days;
  };

  const calendarDays = getDaysInMonth(calendarDate);
  const weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  const priorityColors: Record<string, string> = {
    LOW: "bg-slate-100 text-slate-700 border-slate-200",
    MEDIUM: "bg-blue-50 text-blue-700 border-blue-100",
    HIGH: "bg-orange-50 text-orange-700 border-orange-100",
    URGENT: "bg-red-100 text-red-700 border-red-200 animate-pulse",
  };

  const statusColors: Record<string, string> = {
    TODO: "bg-slate-100 text-slate-700",
    IN_PROGRESS: "bg-indigo-50 text-indigo-700",
    REVIEW: "bg-amber-50 text-amber-700",
    BLOCKED: "bg-rose-50 text-rose-700",
    DONE: "bg-emerald-50 text-emerald-700",
  };

  if (projectLoading || tasksLoading) {
    return (
      <div className="flex items-center justify-center min-h-[50vh]">
        <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600" />
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-in fade-in duration-200">
      
      {/* Title & Navigation Bar */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-gray-100 pb-5">
        <div className="flex items-center gap-3">
          <button
            onClick={() => navigate(`/teams/${teamId}`)}
            className="p-1.5 hover:bg-gray-100 border border-gray-200 rounded-lg text-gray-600 transition-colors"
          >
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <div>
            <h1 className="text-2xl font-bold text-gray-900 font-inter">{project?.name} Tasks</h1>
            <p className="text-xs text-gray-500 font-inter mt-1">Status columns, backlog assignment, and list view toggles.</p>
          </div>
        </div>
        <button
          onClick={() => setShowCreateModal(true)}
          className="px-4 py-2 text-white bg-indigo-600 hover:bg-indigo-700 text-sm font-semibold rounded-lg font-inter flex items-center gap-2 shadow-xs cursor-pointer"
        >
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Add Task
        </button>
      </div>

      {/* Mode Selectors & Query Controls */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-4 border border-gray-200 rounded-xl shadow-xs">
        
        {/* Toggle Mode */}
        <div className="flex bg-gray-100 p-0.5 rounded-lg border border-gray-200/80">
          {(["board", "list", "calendar"] as TaskViewMode[]).map((mode) => (
            <button
              key={mode}
              onClick={() => setViewMode(mode)}
              className={`px-3 py-1.5 rounded-md text-xs font-bold font-inter capitalize transition-all cursor-pointer ${
                viewMode === mode
                  ? "bg-white text-indigo-600 shadow-xs"
                  : "text-gray-500 hover:text-gray-900"
              }`}
            >
              {mode}
            </button>
          ))}
        </div>

        {/* Filters */}
        <div className="flex items-center gap-3 flex-wrap">
          <input
            type="text"
            placeholder="Search tasks..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="px-3 py-1.5 border border-gray-300 rounded-lg text-xs font-inter w-48 bg-white focus:outline-hidden"
          />
          <button
            onClick={() => setShowBacklog(!showBacklog)}
            className={`px-3 py-1.5 rounded-lg border text-xs font-bold font-inter transition-all cursor-pointer ${
              showBacklog
                ? "bg-indigo-50 border-indigo-200 text-indigo-700"
                : "bg-white border-gray-300 text-gray-700 hover:bg-gray-50"
            }`}
          >
            {showBacklog ? "Hide Backlog" : "Show Backlog"}
          </button>
        </div>

      </div>

      {/* BOARD VIEW */}
      {viewMode === "board" && (
        <DragDropContext onDragEnd={handleDragEnd}>
          <div className="flex md:grid overflow-x-auto md:overflow-x-visible md:grid-cols-5 gap-4 items-start min-h-[500px] pb-4">
            {([
              { id: "TODO", title: "📝 To Do", color: "bg-slate-50 border-slate-100" },
              { id: "IN_PROGRESS", title: "🚧 In Progress", color: "bg-blue-50/50 border-blue-100" },
              { id: "REVIEW", title: "👀 Review", color: "bg-amber-50/50 border-amber-100" },
              { id: "BLOCKED", title: "🚫 Blocked", color: "bg-rose-50/50 border-rose-100" },
              { id: "DONE", title: "✅ Done", color: "bg-emerald-50/50 border-emerald-100" },
            ] as const).map((col) => (
              <div key={col.id} className={`${col.color} border rounded-xl p-4 flex flex-col h-[550px] w-[280px] shrink-0 md:w-auto`}>
                <div className="flex items-center justify-between mb-4 border-b border-black/5 pb-2 shrink-0">
                  <h3 className="font-bold text-gray-900 text-xs tracking-wider uppercase font-inter">{col.title}</h3>
                  <span className="text-[10px] bg-white border border-black/5 text-gray-500 font-bold px-2 py-0.5 rounded-full font-inter">
                    {activeBoard[col.id]?.length || 0}
                  </span>
                </div>
                
                <Droppable droppableId={col.id}>
                  {(provided) => (
                    <div
                      ref={provided.innerRef}
                      {...provided.droppableProps}
                      className="flex-1 overflow-y-auto space-y-3 pr-1"
                    >
                      {activeBoard[col.id]?.map((task, idx) => (
                        <Draggable key={task.id} draggableId={task.id} index={idx}>
                          {(dragProv) => (
                            <div
                              ref={dragProv.innerRef}
                              {...dragProv.draggableProps}
                              {...dragProv.dragHandleProps}
                              onClick={() => setActiveEditTask(task)}
                              className="p-3 bg-white border border-gray-200/80 hover:border-indigo-400 hover:shadow-xs rounded-xl transition-all cursor-pointer space-y-2.5"
                            >
                              <div className="flex items-start justify-between gap-2">
                                <p className="text-xs font-bold text-gray-900 leading-snug line-clamp-2 font-inter">
                                  {task.title}
                                </p>
                                <span className={`text-[9px] font-bold px-1 rounded-full uppercase shrink-0 font-inter ${priorityColors[task.priority]}`}>
                                  {task.priority}
                                </span>
                              </div>
                              <div className="flex items-center justify-between text-[10px] text-gray-500 font-inter pt-1.5 border-t border-gray-50">
                                <div className="flex items-center gap-1.5">
                                  <div className="w-5 h-5 rounded-full bg-slate-900 border border-slate-800 text-white font-bold flex items-center justify-center text-[9px] font-inter">
                                    {task.assignedTo?.name?.charAt(0).toUpperCase() || "A"}
                                  </div>
                                  <span className="text-[9px] font-bold text-gray-400 font-inter truncate w-16">
                                    {task.assignedTo?.name || "Assign task"}
                                  </span>
                                </div>
                                <span className="text-[9px] bg-slate-100 text-slate-500 font-bold px-1 rounded-sm font-inter">
                                  {task.storyPoints || 0} SP
                                </span>
                              </div>
                            </div>
                          )}
                        </Draggable>
                      ))}
                      {provided.placeholder}
                    </div>
                  )}
                </Droppable>
              </div>
            ))}
          </div>
        </DragDropContext>
      )}

      {/* LIST VIEW */}
      {viewMode === "list" && (
        <div className="bg-white border border-gray-200 rounded-xl overflow-hidden shadow-xs">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="bg-gray-50 text-gray-500 font-bold uppercase tracking-wider border-b border-gray-200 font-inter">
                <th className="p-4">Task Title</th>
                <th className="p-4">Status</th>
                <th className="p-4">Priority</th>
                <th className="p-4">Story Points</th>
                <th className="p-4">Assignee</th>
                <th className="p-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filteredTasks.length === 0 ? (
                <tr>
                  <td colSpan={6} className="p-8 text-center text-gray-500 font-semibold font-inter">
                    No tasks found matching your filters.
                  </td>
                </tr>
              ) : (
                filteredTasks.map((t) => (
                  <tr key={t.id} className="hover:bg-gray-50 transition-colors">
                    <td
                      onClick={() => setActiveEditTask(t)}
                      className="p-4 font-bold text-gray-900 cursor-pointer font-inter"
                    >
                      {t.title}
                    </td>
                    <td className="p-4">
                      <span className={`px-2 py-0.5 rounded-full text-[9px] font-bold font-inter ${statusColors[t.status]}`}>
                        {t.status}
                      </span>
                    </td>
                    <td className="p-4">
                      <span className={`px-2 py-0.5 rounded-full text-[9px] font-bold font-inter border ${priorityColors[t.priority]}`}>
                        {t.priority}
                      </span>
                    </td>
                    <td className="p-4 font-mono font-bold text-gray-700 font-inter">{t.storyPoints || 0} SP</td>
                    <td className="p-4 font-inter text-gray-600">{t.assignedTo?.name || "Assign task"}</td>
                    <td className="p-4 text-right">
                      <button
                        onClick={() => {
                          if (window.confirm("Delete this task?")) {
                            deleteTaskMutation.mutate(t.id);
                          }
                        }}
                        className="text-gray-400 hover:text-red-600 p-1 cursor-pointer"
                      >
                        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* CALENDAR VIEW */}
      {viewMode === "calendar" && (
        <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-xs space-y-4">
          <div className="flex items-center justify-between border-b border-gray-100 pb-3">
            <h3 className="font-bold text-gray-900 text-sm font-inter">Project Task Scheduler</h3>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setCalendarDate(new Date(calendarDate.getFullYear(), calendarDate.getMonth() - 1, 1))}
                className="p-1 hover:bg-gray-100 border border-gray-200 rounded-lg text-gray-600 cursor-pointer"
              >
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                </svg>
              </button>
              <span className="text-sm font-bold text-gray-800 font-inter min-w-36 text-center">
                {calendarDate.toLocaleDateString(undefined, { month: "long", year: "numeric" })}
              </span>
              <button
                onClick={() => setCalendarDate(new Date(calendarDate.getFullYear(), calendarDate.getMonth() + 1, 1))}
                className="p-1 hover:bg-gray-100 border border-gray-200 rounded-lg text-gray-600 cursor-pointer"
              >
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                </svg>
              </button>
            </div>
          </div>

          <div className="grid grid-cols-7 gap-2 text-center text-xs font-bold text-gray-400 uppercase tracking-wider font-inter">
            {weekDays.map((d) => <div key={d} className="py-1">{d}</div>)}
          </div>

          <div className="grid grid-cols-7 gap-2 border border-gray-100 rounded-xl bg-gray-50 p-2 min-h-[300px]">
            {calendarDays.map((day, idx) => {
              if (!day) return <div key={`empty-${idx}`} className="bg-transparent" />;

              const dayTasks = filteredTasks.filter((t) => {
                if (!t.dueDate) return false;
                const due = new Date(t.dueDate);
                return (
                  due.getDate() === day.getDate() &&
                  due.getMonth() === day.getMonth() &&
                  due.getFullYear() === day.getFullYear()
                );
              });

              return (
                <div
                  key={day.toISOString()}
                  className="bg-white border border-gray-200/80 rounded-lg p-2 min-h-20 flex flex-col justify-between"
                >
                  <span className="text-xs font-bold text-gray-400 font-inter">{day.getDate()}</span>
                  <div className="flex-1 overflow-y-auto space-y-1 mt-1">
                    {dayTasks.map((t) => (
                      <div
                        key={t.id}
                        onClick={() => setActiveEditTask(t)}
                        title={t.title}
                        className="text-[9px] font-bold text-white px-1.5 py-0.5 rounded-sm truncate cursor-pointer leading-tight"
                        style={{
                          backgroundColor:
                            t.priority === "URGENT"
                              ? "#ef4444"
                              : t.priority === "HIGH"
                                ? "#f97316"
                                : t.priority === "MEDIUM"
                                  ? "#3b82f6"
                                  : "#94a3b8",
                        }}
                      >
                        {t.title}
                      </div>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* Add/Create Task Modal Form */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-xs flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl shadow-xl border border-gray-200 w-full max-w-lg overflow-hidden animate-in fade-in zoom-in-95 duration-150">
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
              <h3 className="font-bold text-gray-900 text-lg font-inter">Create Task</h3>
              <button onClick={() => setShowCreateModal(false)} className="text-gray-400 hover:text-gray-600 transition-colors">
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                createTaskMutation.mutate();
              }}
              className="p-6 space-y-4"
            >
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Title</label>
                <input
                  type="text"
                  required
                  placeholder="Task title..."
                  value={createTitle}
                  onChange={(e) => setCreateTitle(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Description</label>
                <textarea
                  placeholder="Add details..."
                  value={createDesc}
                  onChange={(e) => setCreateDesc(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500 h-20"
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Initial Status</label>
                  <select
                    value={createStatus}
                    onChange={(e) => setCreateStatus(e.target.value as TaskStatus)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white focus:outline-hidden"
                  >
                    <option value="TODO">Todo</option>
                    <option value="IN_PROGRESS">In Progress</option>
                    <option value="REVIEW">Review</option>
                    <option value="BLOCKED">Blocked</option>
                    <option value="DONE">Done</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Priority Tier</label>
                  <select
                    value={createPriority}
                    onChange={(e) => setCreatePriority(e.target.value as TaskPriority)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white focus:outline-hidden"
                  >
                    <option value="LOW">Low</option>
                    <option value="MEDIUM">Medium</option>
                    <option value="HIGH">High</option>
                    <option value="URGENT">Urgent</option>
                  </select>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Assignee</label>
                  <select
                    value={createAssigneeId}
                    onChange={(e) => setCreateAssigneeId(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white focus:outline-hidden"
                  >
                    <option value="">Assign task</option>
                    {members.map((m) => (
                      <option key={m.id} value={m.user?.id || ""}>{m.user?.name || "Unknown User"}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Story Points (SP)</label>
                  <input
                    type="number"
                    min="0"
                    value={createPoints}
                    onChange={(e) => setCreatePoints(parseInt(e.target.value) || 0)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4 items-center">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Sprint Planning</label>
                  <select
                    value={createSprintId}
                    onChange={(e) => setCreateSprintId(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white focus:outline-hidden"
                  >
                    <option value="">Backlog (No Sprint)</option>
                    {sprints.map((s) => (
                      <option key={s.id} value={s.id}>{s.name} ({s.status})</option>
                    ))}
                  </select>
                </div>
                <div className="flex items-center gap-2 pt-5">
                  <input
                    id="createIsBacklogCheckbox"
                    type="checkbox"
                    checked={createIsBacklog}
                    onChange={(e) => setCreateIsBacklog(e.target.checked)}
                    className="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                  />
                  <label htmlFor="createIsBacklogCheckbox" className="text-xs font-semibold text-gray-700 font-inter cursor-pointer">
                    Place in Backlog
                  </label>
                </div>
              </div>
              <div className="flex items-center justify-end gap-2 pt-2 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setShowCreateModal(false)}
                  className="px-4 py-2 border border-gray-300 hover:bg-gray-50 text-sm font-medium rounded-lg font-inter cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold rounded-lg font-inter cursor-pointer transition-colors"
                >
                  Create Task
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit Task Modal mounting */}
      {activeEditTask && (
        <EditTaskModal
          task={activeEditTask}
          projectId={projectId as string}
          teamId={teamId}
          onClose={() => {
            setActiveEditTask(null);
            queryClient.invalidateQueries({ queryKey: ["tasks", projectId] });
          }}
        />
      )}

    </div>
  );
}
