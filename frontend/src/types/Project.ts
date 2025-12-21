export interface Project {
  id: string;
  name: string;
  ownerId: string;
  createdAt: string;
  _count?: {
    tasks: number;
  };
}