source("https://raw.githubusercontent.com/OscarVDelatorreTorres/yahooFinance/main/datosMultiplesYahooFinance.R")
source("https://raw.githubusercontent.com/OscarVDelatorreTorres/riskManagementSuiteR/refs/heads/main/riskManagementSuiteFunctions.R")

# Ejemplo para descargar los históricos diarios de grupo Alfa (en moneda local), Microsoft en EEUU (convertido a MXN), Mercado Libre en EEUU (convertido a MXN) y el índice S&P/BMV IPC (en moneda local), desde el 1 de enero de 2023 a la fecha actual:
tickerV=c("BIMBOA","^MXX")
deD="2024-12-31"
hastaD="2023-08-19"
per="D"
paridadFX="USDMXN=X"
convertirFX=rep(FALSE,length(tickerV))

Datos=historico_multiples_precios(tickers=tickerV,de=deD,hasta=hastaD,periodicidad=per,fxRate=paridadFX,whichToFX=convertirFX)

wi=rep((1/length(tickerV)),length(tickerV))

portafolioReturns=rowSums(Datos$tablaRendimientosCont[,2:5]*wi)

rollEWSigma98=rollEWSigma(portafolioReturns,lambda=0.98,ventana=250,upDown=TRUE)
t=1

CVaRsEWSigma98=CVaR(M=100000,sigma=rollEWSigma98,confidence=0.98,pdfFunct="norm",VaRt=1,tsLength=0)
CVaRsEWSigma98=CVaRsEWSigma98/100000

rollGARCHGauss=rollGARCH(portafolioReturns,model="sGARCH",LLF="norm",garchOrder=c(1,1),ventana=50,
                       arma=c(0,0),include.mean = FALSE,upDown=TRUE)

CVaRsGARCHGauss=CVaR(M=100000,sigma=rollGARCHGauss,confidence=0.98,pdfFunct="norm",VaRt=1,tsLength=0)
CVaRsGARCHGauss=CVaRsGARCHGauss/100000

bacckTestEWSigma98=backTestBinomial(portafolioReturns,rollEWSigma98,0.05)
bacckTestGARCHGauss=backTestBinomial(portafolioReturns,CVaRsGARCHGauss,0.05)

bacckTestEWSigma98$Statistic
bacckTestEWSigma98$twoSidedCriticalValue

bacckTestGARCHGauss$Statistic
bacckTestGARCHGauss$twoSidedCriticalValue
