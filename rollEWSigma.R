# roollEWSigma funcion
# Author/Autor: Dr. Oscar V. De la Torre-Torres https://oscardelatorretorres.com

# roollEWSigma v 1.0: 2024-09-03

# Function roollEWSigma is a function for riskmanagement and backtesting purposes. 
# It calculates the rolling volatility of the exponentially weighted moving average 
# of a time series using a given the lambda value:
# La función roollEWSigma es una función para propósitos de gestión de riesgo y backtesting.
# Calcula la volatilidad en ventanas móviles de la media móvil exponencialmente ponderada
# de una serie de tiempo utilizando el valor de lambda:

if (!require(zoo)){install.packages('zoo') 
  library(zoo)} else {library('zoo')}
if (!require(rugarch)){install.packages('rugarch') 
  library(rugarch)} else {library('rugarch')}
 
# roollEWSigma function: 
# Función roollEWSigma:
roollEWSigma=function(x,lambda,lastIsFirst=FALSE,ventana){
  
  
sigmaR=rollapply(x, width = ventana, FUN = function(x) funEWSigma(x,lambda,lastIsFirst), fill = NA, align = "right")
return(sigmaR)
}

# date-specific GARCH estimation auxiliary function:
# Función auxiliar para la estimación de GARCH específica por fecha:
funEWSigma=function(x,lambda,lastIsFirst){

  if (isFALSE(lastIsFirst)){
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

