
source("https://raw.githubusercontent.com/OscarVDelatorreTorres/yahooFinance/main/datosMultiplesYahooFinance.R")

tickerV=c("^MXX","NAFTRACISHRS.MX","DIABLOI10.MX","ALFAA.MX","AC.MX",
          "ASURB.MX","BIMBOA.MX","BOLSAA.MX","CEMEXCPO.MX","FEMSAUBD.MX",
          "CHDRAUIB.MX","GFNORTEO.MX","GMEXICOB.MX","PINFRA.MX","WALMEX.MX",
          "^DJI","^IXIC","AAPL","AMZN","AZO",
          "BOA","C","DELL","GOOGL","MSFT",
          "TSLA","QQQ","IDU","WM")
convertirFX=c(T,T,T,T,T,
              T,T,T,T,T,
              T,T,T,T,T,
              F,F,F,F,F,
              F,F,F,F,F,
              F,F,F,F)
deD="2013-01-01"
hastaD="2024-09-10"
per1="D"
per2="W"

ruta="/Users/oscardelatorretorres/Documents/GitHub/riskManagementSuiteR/"

# Datos diarios:====
datosDiarios=historico_multiples_precios(tickers=tickerV,de=deD,hasta=hastaD,periodicidad="D",
                                         fxRate="USDMXN=X",
                                         whichToFX=convertirFX)
# Escribe los datos en un archivo CSV:
write.csv(datosDiarios$tablaPL,file=paste(ruta,"PLDiario.csv",sep=""))

write.csv(datosDiarios$tablaRendimientosArit,file=paste(ruta,"renAritDiario.csv",sep=""))

write.csv(datosDiarios$tablaRendimientosCont,file=paste(ruta,"renContDiario.csv",sep=""))

# Datos semanales:====
datosSemanales=historico_multiples_precios(tickers=tickerV,de=deD,hasta=hastaD,periodicidad="W",
                                         fxRate="USDMXN=X",
                                         whichToFX=convertirFX)
# Escribe los datos en un archivo CSV:
write.csv(datosSemanales$tablaPL,file=paste(ruta,"PLSemanal.csv",sep=""))

write.csv(datosSemanales$tablaRendimientosArit,file=paste(ruta,"renAritSemanal.csv",sep=""))

write.csv(datosSemanales$tablaRendimientosCont,file=paste(ruta,"renContSemanal.csv",sep=""))
