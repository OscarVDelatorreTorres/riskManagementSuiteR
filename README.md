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
source("https://raw.githubusercontent.com/OscarVDelatorreTorres/riskManagementSuiteR/main/riskManagementSuiteFunctions.R")
```
Después de correr el código anterior en su consola de R, deberá ver la función cargada en su ambiente de trabajo (si está trabajando en Rstudio).

## Ejemplos de uso
### funEWSigma
Esta función calcula la desviación estándar con suavizamiento exponencial, dado un parámetro de suavizamiento $\lambda$. Solo requiere tres argumentos:

- x: la serie de tiempo a la que se le calculará la volatilidad deseada.
- lambda: el valor o coeficiente de suavizamiento exponencia que debe ser un número decimal mayor a cero y menor a 1.
- upDown: un valor lógico (TRUE o FALSE). El valor por defecto es TRUE e indica que la serie de tiempo está ordenada de los valores más antiguos (arriba) a los más reciente (abajo). En caso de tener un orden contrario, la serie de tiempo del objeto x (valores recientes arriba y antiguoa abajo) se debe especificar como FALSE este argumento. El valor por defecto es TRUE.

Ejemplo 1:
```{r}
# Carga los rendimientos del ejemplo (serie de tiempo):
returns=read.csv("https://raw.githubusercontent.com/OscarVDelatorreTorres/riskManagementSuiteR/main/returns.csv")
# Corre el modelo sigmaEWMA con un nivel de suavizamiento exponencial de 0.98 y con una serie de tiempo con los valores antiguos arriba y los recientes abajo:
ewSigma=funEWSigma(returns$return,lambda=0.98,upDown=TRUE)
```

### rollEWMASigma

Esta función emplea la anterior para calcular la desviación estándar con suavizamiento exponencial de manera móvil desde una ventana de tiempo fija $v$ para las realizaciones (observaciones) de una serie de tiempo $x_t$ que van desde $x_{t=v}$ a $x_T$. El siguiente ejemplo calcula la desviación estándar con suavizamiento exponencial del ejemplo anterior para una ventana de tiempo de 30 días

Ejemplo 1:
```{r}
# Carga los rendimientos del ejemplo (serie de tiempo):
returns=read.csv("https://raw.githubusercontent.com/OscarVDelatorreTorres/riskManagementSuiteR/main/returns.csv")
# Corre el modelo sigmaEWMA con un nivel de suavizamiento exponencial de 0.98 y con una serie de tiempo con los valores antiguos arriba y los recientes abajo:
rollEWSigma30=rollEWSigma(returns$return,lambda=0.98,ventana=30,upDown=TRUE)
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
# Carga los rendimientos del ejemplo (serie de tiempo):
returns=read.csv("https://raw.githubusercontent.com/OscarVDelatorreTorres/riskManagementSuiteR/main/returns.csv")
# Corre el modelo gARCH con los valores por defecto:
garchSigma=funGARCH(returns$return)
```

Ejemplo 2:
```{r}
# Carga los rendimientos del ejemplo (serie de tiempo):
returns=read.csv("https://raw.githubusercontent.com/OscarVDelatorreTorres/riskManagementSuiteR/main/returns.csv")
# Corre el modelo E-GARCH con función LLF t-Student y modelo ARMA (1,1) sin ser incluido en el cálculo del modelo GARCH:
garchSigma=funGARCH(returns$return,LLF="std",garchOrder=c(1,1),arma=c(1,1),include.mean=FALSE)
```

### rollGARCH
Esta función emplea la anterior para calcular la desviación estándar GARCH, empleando una ventana de tiempo fija $v$ para las realizaciones (observaciones) de una serie de tiempo $x_t$ que van desde $x_{t=v}$ a $x_T$. El siguiente ejemplo calcula la desviación estándar GARCH del ejemplo anterior para una ventana de tiempo de 30 días, emplando el ejemplo 1 de la función funGARCH

Ejemplo 1:
```{r}
# Carga los rendimientos del ejemplo (serie de tiempo):
returns=read.csv("https://raw.githubusercontent.com/OscarVDelatorreTorres/riskManagementSuiteR/main/returns.csv")

# Corre el modelo sigmaEWMA con un nivel de suavizamiento exponencial de 0.98 y con una serie de tiempo con los valores antiguos arriba y los recientes abajo:
rollGARCH30=rollGARCH(returns$return,model="sGARCH",LLF="std",garchOrder=c(1,1),ventana=30,arma=c(1,1),include.mean = FALSE,upDown=TRUE)

# Imprime el vector resultante:
rollGARCH30
```

## Control de versiones

- V 1.0. 17 de septiembre de 2024: Se calculan las desviaciones estándar con suavizamiento exponencial y con el modelo GARCH tanto en $t$ como de manera móvil desde $x_{t=v}$ a $x_T$ con $v<T$.
