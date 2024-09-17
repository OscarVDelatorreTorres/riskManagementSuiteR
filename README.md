# riskManagementSuiteR
[English version](/readMeEnglish.md)

## Presentación

Este repositorio contiene algunas funciones útiles para cálculos relativos a la cuantificación de riesgos financieros. La misma se ha programado para apoyar este tipo de actividades a nivel profesional y, de manera complementaria, se ha programado como material de apoyo de la materia de **administración de riesgos** de la **Licenciatura en Actuaría y Ciencia de Datos** de la Universidad Michoacana de San Nicolás de Hidalgo.

La misma comprende de las siguientes funciones:

1. funEWSigma: Función que se utiliza para calcular una la volatilidad con suavizamiento exponencial, dado un valor de suavizamiento $\lambda$ y partiendo de una serie de tiempo $x$.
2. rollEWMASigma: Función que aplica la función anterior en una serie de tiempo, utilizando una ventana móvil de longitud previament determinada. Se utiliza para fines de backtest univariados.
3. funGARCH: Función similar a funEWSigma que, a diferencia de la anterior, calcula una volatilidad GARCH definiendo múltiples parámetros y supuestos como es calcular un modelo ARIMA o ARFIMA, así como desviaciones estándar GARCH simétricas y asimétricas. Lo anterior de la mano de supuestos como emplear funciones de verosimilitud gaussianas, t-Student o GED tanto simétricas como asimétricas.
4. rollGARCH: Función que se utiliza la función anterior para calcular modelos GARCH de manera móvil. Esto en una serie de tiempo y con una ventana móvil para los cálculos.
5. CVaR: Esta función calcula el CVaR, dado un vector de 1 a $n$ desviaciones estándar, un vector de $n$ niveles de confianza, una función de probabilidad para el cálculo (gaussiana. t-Student o GED) y el número de periodos $t$ hacia adelante para el cálculo de la pérdida potencial. 

## Carga de funciones

Las funciones en este repositorio se encuentran en fase beta y se contempla crear una librería de R. Para pdoer accedr a las mismas, se debe cargar en la memoria RAM lasmismas con la siguiente función:

```{r}
source("https://raw.githubusercontent.com/OscarVDelatorreTorres/riskManagementSuiteR/main/riskManagementSuiteFunctions.R")
```
Después de correr el código anterior en su consola de R, deberá ver la función cargada en su ambiente de trabajo (si está trabajando en Rstudio).

## Ejemplos de uso

## Control de versiones

- V 1.0. 17 de septiembre de 2024.
