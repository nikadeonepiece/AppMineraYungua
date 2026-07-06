import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { Response } from 'express';
import puppeteer from 'puppeteer';
import { PDFDocument } from 'pdf-lib';

@Injectable()
export class PdfService {
  private readonly launchArgs = [
    '--no-sandbox',
    '--disable-setuid-sandbox',
    '--disable-dev-shm-usage',
    '--allow-file-access-from-files',
  ];

  async generarPdf(html: string, nombreArchivo: string, res: Response) {
    try {
      const pdfBuffer = await this.renderHtmlToPdf(html);
      this.enviarPdf(res, nombreArchivo, pdfBuffer);
    } catch (error) {
      console.error('Error generando PDF genérico:', error);
      throw new InternalServerErrorException('Error al generar el documento PDF');
    }
  }

  async generarPdfPorHojas(hojasHtml: string[], nombreArchivo: string, res: Response) {
    if (hojasHtml.length === 0) {
      throw new InternalServerErrorException('No hay contenido para generar el PDF');
    }
    if (hojasHtml.length === 1) {
      return this.generarPdf(hojasHtml[0], nombreArchivo, res);
    }

    try {
      const browser = await puppeteer.launch({ headless: true, args: this.launchArgs });
      const merged = await PDFDocument.create();

      for (const hojaHtml of hojasHtml) {
        const page = await browser.newPage();
        await page.setDefaultTimeout(300_000);
        await page.setContent(hojaHtml, { waitUntil: 'load' });
        const buf = await page.pdf({
          format: 'A4',
          printBackground: true,
          margin: { top: '6px', bottom: '6px', left: '6px', right: '6px' },
        });
        await page.close();

        const doc = await PDFDocument.load(buf);
        const copied = await merged.copyPages(doc, doc.getPageIndices());
        copied.forEach((p) => merged.addPage(p));
      }

      await browser.close();
      const pdfBytes = await merged.save();
      this.enviarPdf(res, nombreArchivo, Buffer.from(pdfBytes));
    } catch (error) {
      console.error('Error generando PDF por hojas:', error);
      throw new InternalServerErrorException('Error al generar el documento PDF');
    }
  }

  private async renderHtmlToPdf(html: string): Promise<Buffer> {
    const browser = await puppeteer.launch({ headless: true, args: this.launchArgs });
    const page = await browser.newPage();
    await page.setDefaultTimeout(300_000);
    await page.setContent(html, { waitUntil: 'load' });
    const pdfBuffer = await page.pdf({
      format: 'A4',
      printBackground: true,
      margin: { top: '6px', bottom: '6px', left: '6px', right: '6px' },
    });
    await browser.close();
    return Buffer.from(pdfBuffer);
  }

  private enviarPdf(res: Response, nombreArchivo: string, pdfBuffer: Buffer) {
    res.set({
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename=${nombreArchivo}.pdf`,
      'Content-Length': pdfBuffer.length,
    });
    res.end(pdfBuffer);
  }
}