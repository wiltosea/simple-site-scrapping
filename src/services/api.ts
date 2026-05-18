export const fetchApiData = async (url: string) => {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Erro ao buscar API: ${res.status}`);
  return await res.json();
};
