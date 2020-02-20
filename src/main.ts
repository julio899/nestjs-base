import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Logger } from '@nestjs/common';

import {config as configDotenv} from 'dotenv';
import {resolve} from 'path'

const logger = new Logger('AppMain');

if(!process.env.PORT_SOCKET){
  // Validacion Previa cuando corre el Hilo de Socket 
  // corre de forma independiente incluso antes de cargar el archivo .env
  // con esta validacion se indica que si aun no lo ha cargado que lo cargue
  // es decir que cargue todas las variables que se encuentran en el .env
  configDotenv({
    path: resolve(__dirname, "../.env")
  });  
}

async function bootstrap() {
  const app = await NestFactory.create(AppModule,{ cors: true });

  app.enableCors({
      origin: true,
      methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
      credentials: true,
  });
  await app.listen(process.env.PORT);
}
logger.log(`App ejecutando en el Puerto: [ ${process.env.PORT} ]`);
bootstrap();
