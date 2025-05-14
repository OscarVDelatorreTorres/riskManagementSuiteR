# riskManagementSuiteR
[English version](/readMeEnglish.md)

## Presentación

Este repositorio contiene algunas funciones útiles para cálculos relativos a la cuantificación de riesgos financieros. La misma se ha programado para apoyar este tipo de actividades a nivel profesional y, de manera complementaria, se ha programado como material de apoyo de la materia de **administración de riesgos** de la **Licenciatura en Actuaría y Ciencia de Datos** de la Universidad Michoacana de San Nicolás de Hidalgo.

La misma comprende de las siguientes funciones:

1. funEWSigma: Función que se utiliza para calcular una la volatilidad con suavizamiento exponencial, dado un valor de suavizamiento $\lambda$ y partiendo de una serie de tiempo $x$.
2. rollEWMASigma: Función que aplica la función anterior en una serie de tiempo, utilizando una ventana móvil de longitud previament determinada. Se utiliza para fines de backtest univariados.
3. funGARCH: Función similar a funEWSigma que, a diferencia de la anterior, calcula una volatilidad GARCH definiendo múltiples parámetros y supuestos como es calcular un modelo ARIMA o ARFIMA, así como desviaciones estándar GARCH simétricas y asimétricas. Lo anterior de la mano de supuestos como emplear funciones de verosimilitud gaussianas, t-Student o GED tanto simétricas como asimétricas.
4. rollGARCH: Función que se utiliza la función anterior para calcular modelos GARCH de manera móvil. Esto en una serie de tiempo y con una ventana móvil para los cálculos. 

## Carga de funciones

Las funciones en este repositorio se encuentran en fase beta y se contempla crear una librería de R. Para pdoer accedr a las mismas, se debe cargar en la memoria RAM lasmismas con la siguiente función:

```{r}
source("https://raw.githubusercontent.com/OscarVDelatorreTorres/riskManagementSuiteR/refs/heads/main/riskManagementSuiteFunctions.R")
```
Después de correr el código anterior en su consola de R, deberá ver la función cargada en su ambiente de trabajo (si está trabajando en Rstudio).

## Ejemplos de uso
### funEWSigma
Esta función calcula la desviación estándar con suavizamiento exponencial, dado un parámetro de suavizamiento $\lambda$. Solo requiere tres argumentos:

- x: la serie de tiempo a la que se le calculará la volatilidad deseada.
- lambda: el valor o coeficiente de suavizamiento exponencia que debe ser un número decimal mayor a cero y menor a 1.
- upDown: un valor lógico (TRUE o FALSE). El valor por defecto es TRUE e indica que la serie de tiempo está ordenada de los valores más antiguos (arriba) a los más reciente (abajo). En caso de tener un orden contrario, la serie de tiempo del objeto x (valores recientes arriba y antiguoa abajo) se debe especificar como FALSE este argumento. El valor por defecto es TRUE.

Para ejemplificar el uso de las funciones, se asume primero una posición de $1,000.00 en el fondo NAFTRACISHRS.

Ejemplo 1:
```{r}
# Carga los rendimientos del ejemplo (serie de tiempo):
returns=read.csv("https://raw.githubusercontent.com/OscarVDelatorreTorres/riskManagementSuiteR/refs/heads/main/renContSemanal.csv")
# Corre el modelo sigmaEWMA con un nivel de suavizamiento exponencial de 0.98 y con una serie de tiempo con los valores antiguos arriba y los recientes abajo:
ewSigma=funEWSigma(returns$NAFTRACISHRS.MX,lambda=0.98,upDown=TRUE)
```

### rollEWMASigma

Esta función emplea la anterior para calcular la desviación estándar con suavizamiento exponencial de manera móvil desde una ventana de tiempo fija $v$ para las realizaciones (observaciones) de una serie de tiempo $x_t$ que van desde $x_{t=v}$ a $x_T$. El siguiente ejemplo calcula la desviación estándar con suavizamiento exponencial del ejemplo anterior para una ventana de tiempo de 30 días

Ejemplo 1:
```{r}
# Carga los rendimientos del ejemplo (serie de tiempo):
# Corre el modelo sigmaEWMA con un nivel de suavizamiento exponencial de 0.98 y con una serie de tiempo con los valores antiguos arriba y los recientes abajo:
rollEWSigma30=rollEWSigma(returns$NAFTRACISHRS,lambda=0.98,ventana=30,upDown=TRUE)
# Imprime el vector resultante:
rollEWSigma30
```


### funGARCH
Esta función calcula la desviación estándar con suavizamiento exponencial en $t$. La misma tiene los siguientes argumentos de entrada:
- x: la serie de tiempo a la que se le calculará la volatilidad deseada.
- model: Es un objeto tipo spec para especificar el modelo GARCH a estimar. las opciones son
    - "sGARCH" para modelos GARCH simétricos (esta es la opción por defecto).
    - "eGARCH" para modelos EGARCH.
    - "gjrGARCH" para el modelo GJR-GARCH
    - Entre otras opciones de la librería [rugarch](https://cran.r-project.org/web/packages/rugarch/rugarch.pdf)
- LLF: Se refiere a la función de verosimilitud o probabilidad en los residuales del modelo GARCH a utilizar. Las opciones también son heredadas de la librería rugarch y las opciones más comunes son:
    - "norm" para LLF gaussiana simétrica (esta es la opción por defecto).
    - "snorm" para LLF gaussiana asimétrica.
    - "std" para la LLF t-Student simétrica.
    - "sstd" para la LLF t-Student asimétrica.
    - "ged para la LLF GED simétrica.
    - "sged para la LLF GED asimétrica.
- garchOrder: Es el número de rezagos en los términos ARCH y GARCH del modelo GARCH. La opción puede ser garchOrder=c(1,1) (opción por defecto) para especificar un rezago en el término ARCH y uno en el término GARCH.
- arma: Especifica el número de rezagos en el modelo ARMA a estimar. Si se desea calcular la desviación estándar de la media aritmética, se debe especificar arma:c(0,0) (la opción por defecto).
- include.mean: Es el argumento que determina si el modelo GARCH debe incluir la media en los residuales del modelo a estimar. La opción por defecto es include.mean=FALSE.

Esta función devuelve solamente la desviación estándar GARCH calculada en $t$.

Dos ejemplos del uso de la función serían (con la serie de tiempo ya especificada previamente):

Ejemplo 1:
```{r}
# Corre el modelo gARCH con los valores por defecto:
garchSigma=funGARCH(returns$NAFTRACISHRS)
```

Ejemplo 2:
```{r}
# Corre el modelo E-GARCH con función LLF t-Student y modelo ARMA (1,1) sin ser incluido en el cálculo del modelo GARCH:
garchSigma=funGARCH(returns$NAFTRACISHRS,LLF="std",garchOrder=c(1,1),arma=c(1,1),include.mean=FALSE)
```

### rollGARCH
Esta función emplea la anterior para calcular la desviación estándar GARCH, empleando una ventana de tiempo fija $v$ para las realizaciones (observaciones) de una serie de tiempo $x_t$ que van desde $x_{t=v}$ a $x_T$. El siguiente ejemplo calcula la desviación estándar GARCH del ejemplo anterior para una ventana de tiempo de 30 días, emplando el ejemplo 1 de la función funGARCH

Ejemplo 1:
```{r}

# Corre el modelo sigmaEWMA con un nivel de suavizamiento exponencial de 0.98 y con una serie de tiempo con los valores antiguos arriba y los recientes abajo:
rollGARCH30=rollGARCH(returns$NAFTRACISHRS,model="sGARCH",LLF="std",garchOrder=c(1,1),ventana=30,arma=c(1,1),include.mean = FALSE,upDown=TRUE)

# Imprime el vector resultante:
rollGARCH30
```

## VaR

Esta función se puede emplear para calcular el CVaR para un monto (argumento M), dada una desviación estándar (argumento sigma), un nivel de confianza deseados (argumento confidence) y se puede estimar para una función de probabilidad gaussiana (argumento confidenceVector="norm"), t-Student (argumento confidenceVector="t") o para una distribución generalizada por errores (GED, argumento confidenceVector="ged"). La salida es una tabla con el VaR de la sigma y nivel de confianza deseado. El siguiente ejemplo ilustra el cálculo del CVaR para las volatilidades ewSigma y garchSigma previas con niveles de confianza de 95% (0.95):

Ejemplo 1 con la volatilidad exponencialmente suavizada (la calculada previamente) y función de probabilidad gaussiana para una inversión de $1,000.00 en el NAFTRACHISHRS, al 95% de confianza y para un horizonte de 1 día (VaRt=1):

```{r}
# Corre los cálculos del VaR:
M=1000
Sigma=ewSigma
t=1
confianza=0.95
# Se calcula el VaR:
VaR(M=1000,sigma=Sigma,confidence=confianza,pdfFunct="norm",VaRt=t)
```

Ejemplo 2 con la volatilidad GARCH previamente calculada y función de probabilidad t-Student para una inversión de $1,000.00 en el NATRACIHSRS, al 95% de confianza y para un horizonte de 1 día
**Nota:** Para el caso específico de del CVaR con función de probabilidad t-Student debe especificarse la longitud de la serie de tiempo del valor estudiado. Esto se especifica e el argumento `tsLength` De lo contrario, la función generará un error. El argumento `tsLength` es opcional cuando la fución de probabilidad es gaussiana o GED:

```{r}
# Corre los cálculos del VaR:
M=1000
Sigma=garchSigma
t=1
confianza=0.95
# Se calcula el CVaR:
VaR(M=1000,sigma=Sigma,confidence=confianza,pdfFunct="t",VaRt=t,tsLength=100)
```

## CVaR

Esta función es análoga a la función VaR anterior, con la diferencia de que estima el VaR condicional o CVaR. Dicho esto, los ejemplos anteriores se extienden a esta función.

Ejemplo 1 con la volatilidad exponencialmente suavizada (la calculada previamente) y función de probabilidad gaussiana para una inversión de $1,000.00 en el NATRACIHSRS, al 95% de confianza y para un horizonte de 1 día:
```{r}
# Corre los cálculos del CVaR:
M=1000
Sigma=ewSigma
t=1
confianza=0.95
# Se calcula el CVaR:
CVaR(M=1000,sigma=Sigma,confidence=confianza,pdfFunct="norm",CVaRt=t)
```

Ejemplo 2 con la volatilidad GARCH previamente calculada y función de probabilidad t-Student para una inversión de $1,000.00 en el NATRACIHSRS, al 95% de confianza y para un horizonte de 1 día
**Nota:** Para el caso específico de del CVaR con función de probabilidad t-Student debe especificarse la longitud de la serie de tiempo del valor estudiado. Esto se especifica e el argumento `tsLength` De lo contrario, la función generará un error. El argumento `tsLength` es opcional cuando la fución de probabilidad es gaussiana o GED:

```{r}
# Corre los cálculos del CVaR:
M=1000
Sigma=garchSigma
t=1
confianza=0.95
# Se calcula el CVaR:
CVaR(M=1000,sigma=Sigma,confidence=confianza,pdfFunct="t",CVaRt=t,tsLength=100)
```
## Prueba de backtesting de Kupiec: KupiecBackTest

Esta función sirve para determinar si la medida de riesgo es adecuada al realizar una prueba de backtest con el método de la distribución de probabilidad binomial. Esta prueba se conoce como la prueba de Kupiec. Como insumos solo necesita una serie de tiempo de variaciones porcentuales del portafolio o valor al que se le calculará un VaR o CVaR móvin con las funciones VaR o CVaR previamente descritas. También se debe especifirar el nivel de error o significancia $\alpha$ de interés para la prueba. La función regresa el estadístico, que no es más que el conteo de los rendimientos negativos que tienen una magnitud mayor a la del VaR o CVaR estimado para ese periodo.

Se presupone, como se ha comentado, que el conteo de errores está binomialmente distribuido con $1-\alpha$ de probabilidad de éxito.
Su sintaxis es:

KupiecBackTest(returns,riskValues,alphaVal)

## Prueba de backtesting te Christoffersen: chirstoffersenBackTest

Esta función es análoga a la anterior y requiere los mismos insumos de entrada. La diferencia está en que corre la prueba de Christoffersen, consistente no en un estadístico binomial con su correspondiente valor crítico, dada una probabilidad de $1-\alpha$ de tener errores y un valores esperado $N\cdot(1-\alpha)$ de errores, dado el nivel de confianza $\alpha$ del cálculo del VaR o CVAR. Esta prueba regresa el resultado de 3 pruebas:

1. Que el número de veces que la pérdida observada es mayor al Var o CVaR sea igual al esperado (prueba de kupiec previa) ($LR_{cc}$).
2. Que la ocurrencia de cada una de las veces que la pérdida es mayor al VaR o CVaRr sean independientes entre sí (no exista alguna forma de autocorrelacion) ($LR_{ind}$).
3. Que el número de veces en euq la pérdida observada sea mayor a la esperada sea mayor como resultado de la independencia anterior ($LR_{uc}=LR_{cc}+LR_{ind}$).
   
Su sintaxis es:

chirstoffersenBackTest(returns,riskValues,alphaVal)

## Control de versiones

- V 1.0. 17 de septiembre de 2024: Se calculan las desviaciones estándar con suavizamiento exponencial y con el modelo GARCH tanto en $t$ como de manera móvil desde $x_{t=v}$ a $x_T$ con $v<T$.
- V 1.1. 09 de octubre de 2024: Se agregaron las funciones de cálculo del VaR y del CVaR con la media, desviación estándar, nivel de confiaza, periodo de cálculo del VaR o CVaR ($t$) conocidos.
- V 1.1. 11 de febrero de 2024: Se agregó la funcion backTestBinomial que permite, dada una serie de tiempo de rendimientos de un portafolio y una serie de VaR o CVaR estimados con las funciones correspondietes, determinar si la métrica de riesgo calculada (VaR o CVaR) de manera histórica es adecuada o no para la bondad de ajuste.
