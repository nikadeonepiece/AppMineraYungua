import { Module } from '@nestjs/common';
import { CommonService } from './common.service';
import { ExcelService } from './excel.service';
import { PdfService } from './pdf.service';
import { FaceClientService } from './face-client/face-client.service';
import { UploadService } from './upload/upload.service';

@Module({
  providers: [CommonService, PdfService, ExcelService, FaceClientService, UploadService],
  exports: [CommonService, PdfService, ExcelService, FaceClientService, UploadService],
})
export class CommonModule {}