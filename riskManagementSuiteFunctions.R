
# Related libraries:
if (!require(zoo)){install.packages('zoo')
  library(zoo)} else {library('zoo')}
if (!require(Rdpack)){install.packages('Rdpack')
  library(Rdpack)} else {library('rugarch')}
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

# Función rollGARCH:
rollGARCH=function(x,model="sGARCH",LLF="norm",garchOrder=c(1,1),ventana=250,arma=c(0,0),include.mean = FALSE,upDown=TRUE){

  if (isTRUE(upDown)){
    sigmaR=rollapply(x, width = ventana, FUN = function(x) funGARCH(x,model,LLF,garchOrder,arma,include.mean), fill = NA, align = "right")

  } else {
    sigmaR=rollapply(x, width = ventana, FUN = function(x) funGARCH(x,model,LLF,garchOrder,arma,include.mean), fill = NA, align = "left")

  }
  return(sigmaR)
}

# funGARCH====
# date-specific GARCH estimation auxiliary function:
# Función auxiliar para la estimación de GARCH específica por fecha:
funGARCH=function(x,model="sGARCH",LLF="norm",garchOrder=c(1,1),arma=c(0,0),include.mean=FALSE){
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

# funEWSigma====
# date-specific GARCH estimation auxiliary function:
# Función auxiliar para la estimación de GARCH específica por fecha:
funEWSigma=function(x,lambda,upDown=TRUE){

  if (isTRUE(upDown)){
    seqT=seq(to=length(x),from=1,by=1)-1
  } else {
    seqT=seq(from=length(x),to=1,by=-1)-1
  }

  # Se eleva la lambda a la t-1, según la ecuación (3):
  lambdaT=lambda^seqT

  # Se multiplica la lambda suavizada exponencialmente a lo largo de t por los rendimientos al cuadrado:
  rendimientosCuadraticos=(x^2)*lambdaT
  rendimientosSuavizados=rendimientosCuadraticos*lambdaT
  # Se calcula la volatilidad exponencial:
  sigmaExponencial=sqrt((1-lambda)*sum(rendimientosSuavizados))

  return(sigmaExponencial)

}

# CVaR====

# Author/Autor: Dr. Oscar V. De la Torre-Torres https://oscardelatorretorres.com

# CVaR v 1.0: 2024-09-03

# This function estimates CVaR, given an estimated standard deviations vector and a confidence interval
# one

CVaR=function(M,sigma,confidence,pdfFunct,CVaRt,tsLength=0){
  
# errors:
switch(pdfFunct,"t"={
  if (tsLength<1){
    stop("The length of the time series must (argument tsLength) be greater than zero when pdfFunct is t. \n tsLength is the length of the time series used for degrees of freedom calculation.")
  }
}
)

  cat("\f")
  print("Estimating CVaR...")

    cat("\f")
    print(paste0("Estimating with ",pdfFunct,"pdf CVaR at ",confidence*100,"% of confidence..."))

# CVaR estimation===

# CVaR:
      alphaCVaR=1-confidence
      lowZi=-1/sigma
      dlowZi=pnorm(lowZi,0,1)
      pValsSeq=seq(from=dlowZi,to=alphaCVaR,by=0.001)
      pValsSeq=pValsSeq[-1]

      switch(pdfFunct,
             "norm"={
               cvar=(sum((qnorm(pValsSeq,0,1)*sigma)*pValsSeq)*(1/alphaCVaR))*sqrt(CVaRt)
             },
             "t"={
               nu=tsLength-1
               cvar=(sum((qt(pValsSeq,nu)*sigma)*pValsSeq)*(1/alphaCVaR))*sqrt(CVaRt)
             },
             "ged"={
               nu=1
               # q GED estimation:
               lambda = sqrt(2^(-2/nu) * gamma(1/nu)/gamma(3/nu))
               q = lambda * (2 * qgamma((abs(2 * pValsSeq - 1)), 1/nu))^(1/nu)
               gedVal = q * sign(2 * pValsSeq - 1) * 1 + 0

               cvar=(sum((gedVal*sigma)*pValsSeq)*(1/alphaCVaR))*sqrt(CVaRt)
             }
      )
  cvar=M*cvar

  cat("\f")
print(paste0("The CVaR at ",confidence*100,"% of confidence, for an ammount of $",M," is: ",cvar))  
  # output objects:
  return(cvar)

}

# VaR====

# Author/Autor: Dr. Oscar V. De la Torre-Torres https://oscardelatorretorres.com

# VaR v 1.0: 2024-09-03

# This function estimates VaR, given an estimated standard deviations vector and a confidence interval
# one

VaR=function(M,sigma,confidence,pdfFunct,VaRt,tsLength=0){
  
  # errors:
  switch(pdfFunct,"t"={
    if (tsLength<1){
      stop("The length of the time series must (argument tsLength) be greater than zero when pdfFunct is t. \n tsLength is the length of the time series used for degrees of freedom calculation.")
    }
  }
  )
  
  cat("\f")
  print("Estimating VaR...")
  
  cat("\f")
  print(paste0("Estimating with ",pdfFunct,"pdf VaR at ",confidence*100,"% of confidence..."))
  
# VaR estimation===
  
  # VaR:
  alphaVaR=1-confidence
  lowZi=-1/sigma
  dlowZi=pnorm(lowZi,0,1)
  pValsSeq=seq(from=dlowZi,to=alphaVaR,by=0.001)
  pValsSeq=pValsSeq[-1]
  
  switch(pdfFunct,
         "norm"={
           var=qnorm(pValsSeq,0,1)*sigma*sqrt(VaRt)
         },
         "t"={
           nu=tsLength-1
           var=qt(pValsSeq,nu)*sigma*sqrt(VaRt)
         },
         "ged"={
           nu=1
           # q GED estimation:
           lambda = sqrt(2^(-2/nu) * gamma(1/nu)/gamma(3/nu))
           q = lambda * (2 * qgamma((abs(2 * pValsSeq - 1)), 1/nu))^(1/nu)
           gedVal = q * sign(2 * pValsSeq - 1) * 1 + 0
           
           var=gedVal*sigma*sqrt(VaRt)
         }
  )
  var=M*var
  
  cat("\f")
  print(paste0("The VaR at ",confidence*100,"% of confidence, for an ammount of $",M," is: ",var))  
  # output objects:
  return(var)
  
}