# riskManagementSuiteR
[English version](/readMeEnglish.md)

# Presentación

Este repositorio contiene algunas funciones útiles para cálculos relativos a la cuantificación de riesgos financieros. La misma se ha programado para apoyar este tipo de actividades a nivel profesional y, de manera complementaria, se ha programado como material de apoyo de la materia de **administración de riesgos** de la **Licenciatura en Actuaría y Ciencia de Datos** de la Universidad Michoacana de San Nicolás de Hidalgo.

La misma comprende de las siguientes funciones:

1. rollGARCH: Función que se utiliza para calcular un modelo GARCH(p,q), partiendo de una serie de tiempo y una longitud de ventana móvil apra su cálculo. La función es de utilidad para fines de backtesting univariado.
2. rollEWMASigma: Función que se utiliza para calcular un la volatilidad con suavizamiento exponencial, dado un valor de suavizamiento $\lambda$ y partiendo de una serie de tiempo y una longitud de ventana móvil apra su cálculo. La función también es de utilidad para fines de backtesting univariado.
3. CVaR: Esta función calcula el CVaR, dado un vector de 1 a $n$ desviaciones estándar, un vector de $n$ niveles de confianza, una función de probabilidad para el cálculo (gaussiana. t-Studnet o GED) y el número de periodos $t$ hacia adelante para el cálculo de la pérdida potencial. 

a

# Control de versiones

- V 1.0. 17 de septiembre de 2024.
