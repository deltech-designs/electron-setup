// src/preload.ts
import { contextBridge, ipcRenderer } from 'electron';

contextBridge.exposeInMainWorld('api', {
  getStudents: () => ipcRenderer.invoke('get-students'),
  addStudent: (data: { name: string; score: number }) => ipcRenderer.invoke('add-student', data),
});