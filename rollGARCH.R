# roollGARCH funcion
# Author/Autor: Dr. Oscar V. De la Torre-Torres https://oscardelatorretorres.com

# rollGARCH v 1.0: 2024-09-03

# Function rollGARCH is a function for riskmanagement and backtesting purposes. 
# It calculates the rolling volatility of a time series using a GARCH model given
# the specifications of ugarchspec and ugarchfit in the ugarch package.

# La función rollGARCH es una función para propósitos de gestión de riesgo y backtesting.
# Calcula la volatilidad en ventanas móviles de una serie de tiempo utilizando un modelo GARCH
# dadas las especificaciones de ugarchspec y ugarchfit en el paquete ugarch.

if (!require(zoo)){install.packages("zoo") library("zoo")} else {library("zoo")}
if (!require(rugarch)){install.packages("rugarch") library("rugarch")} else {library("rugarch")}
 
# rollGARCH function: 
# Función rollGARCH:
rollGARCH=function(x,model="sGARCH",LLF="norm",garchOrder=c(1,1),ventana=250,arma=c(0,0),include.mean = FALSE){
  
  
sigmaR=rollapply(x, width = ventana, FUN = function(x) funGARCH(x,model,LLF,garchOrder,arma,include.mean), fill = NA, align = "right")
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

