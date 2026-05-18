import { diff } from 'microdiff';

export const compareData = (oldData: any, newData: any): string | null => {
  const changes = diff(oldData, newData);
  if (changes.length === 0) return null;

  const lines = changes.map((c) => {
    const path = c.path.join('.');
    switch (c.type) {
      case 'CREATE':
        return `+ ${path}: ${JSON.stringify(c.value)}`;
      case 'REMOVE':
        return `- ${path}: ${JSON.stringify(c.value)}`;
      case 'UPDATE':
        return `~ ${path}: ${JSON.stringify(c.value)} → ${JSON.stringify(c.newValue)}`;
    }
  });
  return lines.join('\n');
};
