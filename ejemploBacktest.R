source("https://raw.githubusercontent.com/OscarVDelatorreTorres/yahooFinance/main/datosMultiplesYahooFinance.R")

# Ejemplo para descargar los históricos diarios de grupo Alfa (en moneda local), Microsoft en EEUU (convertido a MXN), Mercado Libre en EEUU (convertido a MXN) y el índice S&P/BMV IPC (en moneda local), desde el 1 de enero de 2023 a la fecha actual:
tickerV=c("ALFAA.MX","MSFT","MELI","^MXX")
deD="2020-01-01"
hastaD=Sys.Date()
per="W"
paridadFX="USDMXN=X"
convertirFX=c(FALSE,TRUE,TRUE,FALSE)

Datos=historico_multiples_precios(tickers=tickerV,de=deD,hasta=hastaD,periodicidad=per,fxRate=paridadFX,whichToFX=convertirFX)

wi=rep(0.25,4)

portafolioReturns=rowSums(Datos$tablaRendimientosCont[,2:5]*wi)

rollEWSigma98=rollEWSigma(portafolioReturns,lambda=0.98,ventana=50,upDown=TRUE)
t=1
CVaRs=CVaR(M=100000,sigma=rollEWSigma98,confidence=0.95,pdfFunct="norm",VaRt=1,tsLength=0)
CVaRRel=CVaRs/100000
