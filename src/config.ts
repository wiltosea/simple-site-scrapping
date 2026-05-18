import { config as dotenvConfig } from "dotenv";

dotenvConfig(); // carrega .env

export interface Config {
  smtpServer: string;
  smtpUser: string;
  smtpPass: string;
  emailFrom: string;
  emailTo: string;
  apiUrl: string;
  emailSubject: string;
}

export const config: Config = {
  smtpServer: process.env.SMTP_SERVER ?? "",
  smtpUser: process.env.SMTP_USER ?? "",
  smtpPass: process.env.SMTP_PASS ?? "",
  emailFrom: process.env.EMAIL_FROM ?? "",
  emailTo: process.env.EMAIL_TO ?? "",
  apiUrl: process.env.API_URL ?? "",
  emailSubject: process.env.EMAIL_SUBJECT ?? "Alerta de mudança",
};

// validação básica
for (const [key, value] of Object.entries(config)) {
  if (!value) {
    throw new Error(`Variável de ambiente ${key} está ausente`);
  }
}
