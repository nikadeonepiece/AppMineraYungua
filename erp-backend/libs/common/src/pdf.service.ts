import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { Response } from 'express';
import puppeteer from 'puppeteer';

@Injectable()
export class PdfService {
  async generarPdf(html: string, nombreArchivo: string, res: Response) {
    try {
      const browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'],
      });
      const page = await browser.newPage();
      
      await page.setContent(html, { waitUntil: 'load' });

      const pdfBuffer = await page.pdf({
        format: 'A4',
        printBackground: true,
        margin: { top: '20px', bottom: '20px', left: '20px', right: '20px' },
      });

      await browser.close();

      res.set({
        'Content-Type': 'application/pdf',
        'Content-Disposition': `attachment; filename=${nombreArchivo}.pdf`,
        'Content-Length': pdfBuffer.length,
      });

      res.end(pdfBuffer);
    } catch (error) {
      console.error('Error generando PDF genérico:', error);
      throw new InternalServerErrorException('Error al generar el documento PDF');
    }
  }
}