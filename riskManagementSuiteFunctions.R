
# Related libraries:
if (!require(zoo)){install.packages('zoo')
  library(zoo)} else {library('zoo')}
if (!require(rugarch)){install.packages('rugarch')
  library(rugarch)} else {library('rugarch')}
if (!require(fGarch)){install.packages('fGarch')
  library(fGarch)} else {library('fGarch')}
if (!require(doParallel)){install.packages('doParallel')
  library(doParallel)} else {library('doParallel')}

# rollGARCH ====
# Author/Autor: Dr. Oscar V. De la Torre-Torres https://oscardelatorretorres.com

# rollGARCH v 1.0: 2024-09-03

# Function rollGARCH is a function for riskmanagement and backtesting purposes.
# It calculates the rolling volatility of a time series using a GARCH model given
# the specifications of ugarchspec and ugarchfit in the ugarch package.

# La función rollGARCH es una función para propósitos de gestión de riesgo y backtesting.
# Calcula la volatilidad en ventanas móviles de una serie de tiempo utilizando un modelo GARCH
# dadas las especificaciones de ugarchspec y ugarchfit en el paquete ugarch.

# rollGARCH function:
# Función rollGARCH:
rollGARCH=function(x,model="sGARCH",LLF="norm",garchOrder=c(1,1),ventana=250,arma=c(0,0),include.mean = FALSE,upDown=TRUE){

  if (isTRUE(upDown)){
    sigmaR=rollapply(x, width = ventana, FUN = function(x) funGARCH(x,model,LLF,garchOrder,arma,include.mean), fill = NA, align = "right")

  } else {
    sigmaR=rollapply(x, width = ventana, FUN = function(x) funGARCH(x,model,LLF,garchOrder,arma,include.mean), fill = NA, align = "left")

  }
  return(sigmaR)
}

# date-specific GARCH estimation auxiliary function:
# Función auxiliar para la estimación de GARCH específica por fecha:
funGARCH=function(x,model,LLF,garchOrder,arma,include.mean){
  # Se crea el objeto del modelo GARCH:
  modeloGARCH=ugarchspec(variance.model = list(model = model, garchOrder = garchOrder),
                         mean.model = list(armaOrder = arma, include.mean = include.mean),
                         distribution.model = LLF)

  # Se ajusta el modelo GARCH:
  ajusteGARCH=ugarchfit(spec=modeloGARCH, data=x)
  sigmas=tail(ajusteGARCH@fit$sigma,1)
  return(sigmas)

}



# rollEWSigma====
# Author/Autor: Dr. Oscar V. De la Torre-Torres https://oscardelatorretorres.com

# rollEWSigma v 1.0: 2024-09-03

# Function roollEWSigma is a function for riskmanagement and backtesting purposes.
# It calculates the rolling volatility of the exponentially weighted moving average
# of a time series using a given the lambda value:
# La función roollEWSigma es una función para propósitos de gestión de riesgo y backtesting.
# Calcula la volatilidad en ventanas móviles de la media móvil exponencialmente ponderada
# de una serie de tiempo utilizando el valor de lambda:

# roollEWSigma function:
# Función roollEWSigma:
rollEWSigma=function(x,lambda,ventana,upDown=TRUE){


  sigmaR=rollapply(x, width = ventana, FUN = function(x) funEWSigma(x,lambda,upDown), fill = NA, align = "right")
  return(sigmaR)
}

# date-specific GARCH estimation auxiliary function:
# Función auxiliar para la estimación de GARCH específica por fecha:
funEWSigma=function(x,lambda,upDown=TRUE){

  if (isTRUE(upDown)){
    seqT=seq(to=nrow(rendimientosEjemplo1),from=1,by=1)-1
  } else {
    seqT=seq(from=nrow(rendimientosEjemplo1),to=1,by=-1)-1
  }

  # Se eleva la lambda a la t-1, según la ecuación (3):
  lambdaT=lambdaS^seqT

  # Se multiplica la lambda suavizada exponencialmente a lo largo de t por los rendimientos al cuadrado:
  rendimientosCuadraticos=(x^2)*lambdaT
  rendimientosSuavizados=rendimientosCuadraticos*lambdaT
  # Se calcula la volatilidad exponencial:
  sigmaExponencial=sqrt((1-lambdaS)*sum(rendimientosSuavizados))

  return(sigmaExponencial)

}

# CVaR====

# Author/Autor: Dr. Oscar V. De la Torre-Torres https://oscardelatorretorres.com

# CVaR v 1.0: 2024-09-03

# This function estimates CVaR, given an estimated standard deviations vector and a confidence interval
# one

CVaR=function(riskVector,confidenceVector,pdfFunct,CVaRt,Tlength){
library(fGarch)
cat("\f")
print("Setting CVaR parallel configurations up...")

  # parallel setup:
  #Setup backend to use many processors
  totalCores = detectCores()

  #Leave one core to avoid overload your computer
  cluster <- makeCluster(totalCores[1]-1)
  registerDoParallel(cluster)

  cat("\f")
  print("Estimating CVaR...")

  CVaRTable=as.data.frame(matrix(0,length(riskVector),length(confidenceVector)))
  colnames(CVaRTable)=paste0("CVaR-",confidenceVector)

  for (a in 1:length(confidenceVector)){


    cat("\f")
    print(paste0("Estimating with ",pdfFunct,"pdf CVaR at ",confidenceVector[a]*100,"% of confidence..."))

# CVaR estimation===

    CVarVector=foreach(b=1:length(riskVector),.combine=c)%dopar%{
#      parallelCVaR(riskVector[b],confidenceVector[a],pdfFunct,CVaRt,Tlength)
#---
# parallel CVaR:
      alphaCVaR=1-confidenceVector[a]

      pValsSeq=seq(from=0,to=alphaCVaR,by=0.000001)
      pValsSeq=pValsSeq[-1]

      switch(pdfFunct,
             "norm"={
               zVal=qnorm(pValsSeq,0,1)
               cvar=mean((zVal*riskVector[b])*sqrt(CVaRt))
             },
             "t"={
               nu=Tlength-1
               tVal=qt(pValsSeq,nu)
               cvar=mean((tVal*riskVector[b])*sqrt(CVaRt))
             },
             "ged"={
               nu=1
               # q GED estimation:
               lambda = sqrt(2^(-2/nu) * gamma(1/nu)/gamma(3/nu))
               q = lambda * (2 * qgamma((abs(2 * pValsSeq - 1)), 1/nu))^(1/nu)
               gedVal = q * sign(2 * pValsSeq - 1) * 1 + 0

               cvar=mean((gedVal*riskVector[b])*sqrt(CVaRt))
             }
      )

#---
    }

# CVaR table===
    CVaRTable[,a]=CVarVector
     # a loop ends here:
  }

  # output objects:
  return(CVaRTable)

  #Stopping parallel cluster
 stopCluster(cluster)


}

