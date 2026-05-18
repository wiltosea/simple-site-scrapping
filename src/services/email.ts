import nodemailer from 'nodemailer';
import { config } from '../config';

const transporter = nodemailer.createTransport({
  host: config.smtpServer.replace(/^smtp:\/\/|^smtps:\/\//, ''),
  port: Number(config.smtpServer.split(':')[2] ?? 587),
  secure: config.smtpServer.startsWith('smtps'),
  auth: {
    user: config.smtpUser,
    pass: config.smtpPass,
  },
});

export const sendDiffEmail = async (diffText: string) => {
  await transporter.sendMail({
    from: config.emailFrom,
    to: config.emailTo,
    subject: config.emailSubject,
    text: diffText,
  });
};
