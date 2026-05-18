import { config } from './config';
import { fetchApiData } from './services/api';
import { readPreviousData, saveCurrentData } from './utils/file';
import { compareData } from './utils/diff';
import { sendDiffEmail } from './services/email';
import cron from 'node-cron';

const CURRENT_FILE = './girlpower_current.json';
const PREVIOUS_FILE = './girlpower_previous.json';

const runJob = async () => {
  try {
    const newData = await fetchApiData(config.apiUrl);
    const oldData = await readPreviousData(PREVIOUS_FILE);

    if (!oldData) {
      await saveCurrentData(CURRENT_FILE, newData);
      console.log('Primeira execução – dados salvos.');
      return;
    }

    const diffText = compareData(oldData, newData);
    if (diffText) {
      await sendDiffEmail(diffText);
      console.log('Diferenças encontradas e e‑mail enviado.');
      await saveCurrentData(CURRENT_FILE, newData);
    } else {
      console.log('Nenhuma diferença encontrada.');
    }
  } catch (err) {
    console.error('Erro no job:', err);
  }
};

// execução direta (usado pelo cron interno da fase 7)
runJob();

console.log('Monitoramento iniciado – executando a cada 3 minutos.');
cron.schedule('*/3 * * * *', runJob);
