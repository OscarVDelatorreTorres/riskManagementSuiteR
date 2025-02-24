#a
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
  
  switch(pdfFunct,
         "norm"={
           var=qnorm(alphaVaR,0,1)*sigma*sqrt(VaRt)
         },
         "t"={
           nu=tsLength-1
           var=qt(alphaVaR,nu)*sigma*sqrt(VaRt)
         },
         "ged"={
           nu=1
           # q GED estimation:
           lambda = sqrt(2^(-2/nu) * gamma(1/nu)/gamma(3/nu))
           q = lambda * (2 * qgamma((abs(2 * alphaVaR - 1)), 1/nu))^(1/nu)
           gedVal = q * sign(2 * alphaVaR - 1) * 1 + 0
           
           var=gedVal*sigma*sqrt(VaRt)
         }
  )
  var=M*var
  
  cat("\f")
  #print(paste0("The VaR at ",confidence*100,"% of confidence, for an ammount of $",M," is: ",var))  
  # output objects:
  return(var)
  
}

# CVaR====

# Author/Autor: Dr. Oscar V. De la Torre-Torres https://oscardelatorretorres.com

# CVaR v 1.0: 2024-09-03

# This function estimates CVaR, given an estimated standard deviations vector and a confidence interval
# one

CVaR=function(M,sigma,confidence,pdfFunct,VaRt,tsLength=0){
  
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

  cvarV=rep(NA,length(sigma))
  

# CVaR estimation===

  for (a in 1:length(sigma)){  
# CVaR:
      alphaCVaR=1-confidence
      #lowZi=-1/sigma
      pValsSeq=seq(from=0,to=alphaCVaR,by=0.0001)
      pValsSeq=pValsSeq[-1]

      switch(pdfFunct,
             "norm"={
               qpdf=qnorm(pValsSeq,0,1)
               cvar=mean((qpdf*sigma[a])*sqrt(VaRt))
               
             },
             "t"={
               nu=tsLength-1
               cvar=mean((qt(pValsSeq,nu)*sigma[a])*sqrt(VaRt))
             },
             "ged"={
               nu=1
               # q GED estimation:
               lambda = sqrt(2^(-2/nu) * gamma(1/nu)/gamma(3/nu))
               q = lambda * (2 * qgamma((abs(2 * pValsSeq - 1)), 1/nu))^(1/nu)
               gedVal = q * sign(2 * pValsSeq - 1) * 1 + 0

               cvar=mean((gedVal*sigma[a])*sqrt(VaRt))
             }
      )
  # lopp a ends here:    
  cvarV[a]=M*cvar    
  }


  cat("\f")
#print(paste0("The CVaR at ",confidence*100,"% of confidence, for an ammount of $",M," is: ",cvar))  
  # output objects:
  return(cvarV)

}

# kupiecBackTest====

# Author/Autor: Dr. Oscar V. De la Torre-Torres https://oscardelatorretorres.com

# kupiecBackTest v 1.0: 2025-02-11

# This function estimates the backtest of a VaR model, given the returns of a time series, 
# the estimated VaR or CVaR, and a binomial confidence interval.

KupiecBackTest=function(returns,riskValues,alphaVal){
# violations count:  
  pBinomial=1-alphaVal
  nBinomial=length(returns[which(!is.na(riskValues))])
  expectedExceeds=round(nBinomial*(alphaVal))
  
  exceedsTable=data.frame(Returns=returns,
                          riskMeasure=riskValues)
  
  exceedsTable=exceedsTable[which(!is.na(exceedsTable$riskMeasure)),]
  exceedsTable=exceedsTable[which(!is.na(exceedsTable$Returns)),]
  
  Statistic=length(which(exceedsTable$Returns<exceedsTable$riskMeasure))
  
  criticalValue=qbinom(1-alphaVal,length(returns[which(!is.na(riskValues))]),alphaVal)
  pValue=1-pbinom(Statistic,nBinomial,alphaVal)
 
  
  twoSidedCriticalValue=c(qbinom(alphaVal/2,nBinomial,alphaVal),
                          qbinom((1-alphaVal+alphaVal/2),nBinomial,alphaVal)
                          )

  
# Exit object:
  outObject=list(Statistic=Statistic,
                 pValue=pValue,
                 criticalValue=criticalValue,
                 twoSidedCriticalValue=twoSidedCriticalValue,
                 expectedExceeds=expectedExceeds)
  return(outObject)
}

# Christoffersen bakctest:

# Author/Autor: Dr. Oscar V. De la Torre-Torres https://oscardelatorretorres.com

# chirstoffersenBackTest v 1.0: 2025-02-24

chirstoffersenBackTest=function(returns,riskValues,alphaVal){
  
  # violations count:  
  pBinomial=1-alphaVal
  nBinomial=length(returns[which(!is.na(riskValues))])
  expectedExceeds=round(nBinomial*(alphaVal))
  
  exceedsTable=data.frame(Returns=returns,
                          riskMeasure=riskValues)
  
  exceedsTable=exceedsTable[which(!is.na(exceedsTable$riskMeasure)),]
  exceedsTable=exceedsTable[which(!is.na(exceedsTable$Returns)),]
  
  Statistic=length(which(exceedsTable$Returns<exceedsTable$riskMeasure))
# LRUC of Christoffersen backtest:
  LRuc=-2*log((1-alphaVal)^(nBinomial-Statistic)*(alphaVal^Statistic))+
    2*log(((1-(Statistic/nBinomial))^(nBinomial-Statistic))*(Statistic/nBinomial)^Statistic)  

# LRind of Christoffersen backtest:

violId=rep(0,nBinomial)
violId[which(exceedsTable$Returns<exceedsTable$riskMeasure)]=1

n00=0
n01=0
n11=0
n10=0

for (a in 2:length(violId)){
  if (violId[a]==0 & violId[a-1]==0){
    n00=n00+1
  }
  if (violId[a]==1 & violId[a-1]==1){
    n11=n11+1
  }
  if (violId[a]==0 & violId[a-1]==1){
    n10=n10+1
  }
  if (violId[a]==1 & violId[a-1]==0){
    n01=n01+1
  }  
}

LRucPValue=pchisq(LRuc,1,lower.tail = FALSE)
  
pi01=n01/(n01+n00)
pi11=n11/(n10+n11)
pi2=(n01+n11)/(n00+n10+n01+n11)

LRind=-2*log((1-pi2)^(n00+n11)*pi2^(n01+n11))+2*log((1-pi01)^n00*pi01^n01*(1-pi11)^n10*pi11^n11)
  
LRindPValue=pchisq(LRind,1,lower.tail = FALSE)

LRcc=LRuc+LRind
LRccPValue=pchisq(LRcc,2,lower.tail = FALSE)

  # Exit object:
  outObject=list(Statistic=Statistic,
                 LRuc=LRuc,
                 LRind=LRind,
                 LRcc=LRcc,
                 LRucPValue=LRucPValue,
                 LRindPValue=LRindPValue,
                 LRccPValue=LRccPValue)
  return(outObject)
}



