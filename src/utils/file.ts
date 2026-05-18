import { readFile, writeFile } from 'fs/promises';

export const readPreviousData = async (path: string) => {
  try {
    const raw = await readFile(path, 'utf-8');
    return JSON.parse(raw);
  } catch (e) {
    return null; // arquivo inexistente ou erro → tratado como primeira execução
  }
};

export const saveCurrentData = async (path: string, data: any) => {
  const json = JSON.stringify(data, null, 2);
  await writeFile(path, json, 'utf-8');
};
