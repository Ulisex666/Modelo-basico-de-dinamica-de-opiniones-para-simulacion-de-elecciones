### Propósito y patrones

El propósito del modelo es el estudio de la evolución de las opiniones
en una sociedad, a través de la comunicación entre las personas
presentes en ella y el tipo de influencia entre estas. En este contexto,
*una opinión es la posición que se tiene sobre un tema, y se formaliza
como un número que cambia entre dos extremos*
[@smaldinoModelingSocialBehavior2023 p. 117]. Se espera que las personas
modifiquen sus opiniones después de interactuar con sus pares a través
del efecto de la influencia social. Estas interacciones se dan solamente
entre agentes que se encuentren comunicados mediante una conexión
social. Se consideran tres tipos de influencia diferentes entre los
agentes después de una interacción, tomando la clasificación dada en
[@flacheModelsSocialInfluence2017b].

- **Influencia positiva.** Después de una interacción, dos agentes
  siempre tendrán una opinión más cercana a la del otro. Esto toma como
  base teorías cognitivas que hacen hincapié en el papel del aprendizaje
  social y de la presión social para seguir las normas de un grupo.

- **Confianza acotada.** Un agente es influenciado a tomar una opinión
  más cercana a la del otro agente en la interacción solamente si sus
  opiniones son suficientemente similares. Qué tan parecida debe ser la
  opinión de otro agente está determinado por una cota o límite de
  confianza. La base teórica principal es el sesgo de confirmación, la
  tendencia de preferir información que este de acuerdo con lo que ya se
  opina y evadir aquella que contradiga nuestras creencias.

- **Influencia negativa.** Si dos agentes con opiniones muy disimilares
  interactúan entre ellos, se influencian en sentido opuesto, tomando
  opiniones todavía más dispares. Esto toma como base teórica efectos
  como la xenofobia o el rechazo a grupos percibidos como externos,
  aunque la evidencia empírica de este efecto es mixta.

Los patrones a observar son aquellos clásicos de la literatura de
dinámica de opiniones: consenso, polarización y agrupación de opiniones
[@xiaOpinionDynamicsMultidisciplinary2011a]. El consenso se da cuando la
opinión de todos los agentes en el sistema convergen alrededor de un
mismo valor, con variabilidad mínima. En el otro extremo, se tiene a la
polarización, donde la población se divide en dos grupos con opiniones
completamente en contra. Entre estos dos extremos se encuentra la
agrupación de opiniones, donde los agentes del sistema se concentran en
diversos grupos sobre todo el espectro de opiniones. Se asume que los
patrones observados en el modelo se deba principalmente a las diferentes
formas de interacción entre agentes [@flacheModelsSocialInfluence2017b].

### Entidades, variables de estado y escalas

Las entidades principales del modelo propuesto son los agentes,
representando personas dentro de una sociedad, interactuando con
aquellas personas con las que mantienen una conexión social.

Cada agente se encuentra definido por una variable de estado: su opinión
en un momento dado. Esta es un valor real en el rango $[-1,1]$, donde
$-1$ indica una opinión completamente en contra y $1$ una opinión
completamente a favor. Además de esto, es importante considerar los
vecinos de un agente, que indican aquellos con los que se puede
comunicar.

Se utiliza un mundo cerrado de tamaño 21x21, generando un agente por
segmento. De esta forma, se tiene 441 agentes dentro del modelo. El
tiempo se encuentra representado por ticks, sin un valor específico más
allá del tiempo que se necesita para la interacción entre dos agentes.
El modelo se ejecuta el número de ticks necesario hasta que se llegue a
observar patrones emergentes a escala global.

### Descripción general y *scheduling*

El programa tiene dos acciones principales por tick: la interacción
entre agentes y la actualización de las observaciones del modelo.

Para la interacción entre agentes, se selecciona a uno de manera
aleatoria. Después de esto, se mira a los vecinos de este agente, y de
manera aleatoria se selecciona a uno de ellos para compartir su opinión.
Los dos agentes comparten su opinión de acuerdo al tipo de influencia
que se este modelando siguiendo los submodelos detallados más adelante
en el protocolo.

El siguiente paso es la actualización de las observaciones del modelo,
de forma que el cambio en las opiniones de los agentes se pueda analizar
y visualizar. Igualmente esto se encuentra detallado en la sección de
submodelos. En el algoritmo
[\[alg:opinion_dynamics_cycle\]](#alg:opinion_dynamics_cycle){reference-type="ref"
reference="alg:opinion_dynamics_cycle"} se encuentra la descripción de
este proceso mediante pseudocódigo.

:::: algorithm
::: algorithmic
$A_i \leftarrow$ SELECCIONAR_AGENTE_ALEATORIO $Vecinos \leftarrow$
CONEXIONES  $A_i$ $A_j \leftarrow$ SELECCIONAR_VECINO_ALEATORIO
$\Delta O \leftarrow$ SUBMODELO_DE_INFLUENCIA  $O_i, O_j$
$O_i \leftarrow O_i + \Delta O_i$ $O_j \leftarrow O_j + \Delta O_j$
$Tiempo \leftarrow Tiempo + 1$
:::
::::

### Conceptos de diseño

- **Principios básicos.** La suposición básica en todo modelo de
  dinámica de opinión es que la influencia social tiene un papel
  fundamental a a la hora de formar y modificar opiniones
  [@galesicIntegratingSocialCognitive2021]. En este caso se esta
  considerando que la influencia se da solamente entre aquellos agentes
  que comparten una conexión social cercana. Sumado a ello, cada tipo de
  influencia considerado tiene otras suposiciones sobre el cambio de
  opiniones, cada una con diferentes justificaciones en ciencias
  sociales y psicología [@flacheModelsSocialInfluence2017b].

- **Emergencia.** Los patrones principales a buscar son la distribución
  de opiniones a escala global en el sistema. Se observa la emergencia
  de consenso, polarización o agrupación de opiniones. Estos patrones
  emergen de la interacción entre pares de los agentes del sistema.

- **Adaptación.** Los agentes adaptan su opinión después de interactuar
  con otros agentes presentes en sus conexiones sociales, de acuerdo a
  uno de los tipos de influencia considerados. Para una influencia
  positiva, el agente busca parecerse más a cualquier otra persona en su
  red social. En el caso de confianza acotada, busca solamente parecerse
  a aquellos similares a sí mismo. Para la influencia negativa, busca
  alejar su opinión de aquellas que sean muy disimilares.

- **Objetivos.** Los tres modelos de influencia asumen que un agente
  busca ajustar su opinión de acuerdo a las interacciones con otros en
  sus conexiones sociales. Se difiere en qué agentes son considerados
  suficientemente importantes como para afectar la opinión, y el sentido
  en que lo hacen.

- **Aprendizaje.** Este concepto no se utiliza en el modelo.

- **Predicción.** Este concepto no se utiliza en el modelo.

- **Percepciones.** En la interacción entre agentes, se asume que uno es
  completamente consciente de la opinión del otro sobre el tema a
  discusión.

- **Interacciones.** La interacción a modelar es compartir opinión entre
  pares unidos por una conexión social, y cómo estas opiniones son
  modificadas de acuerdo al tipo de influencia considerado. Estas se dan
  de forma directa, donde la opinión de un agente afecta de la del otro
  de acuerdo al tipo de interacción.

- **Estocásticidad.** Las opiniones iniciales de cada agente se dan de
  forma aleatoria, siguiendo una distribución uniforme. Los agentes a
  interactuar en cada paso de tiempo se seleccionan de manera aleatoria.

- **Colectivos.** Este concepto no se utiliza en el modelo.

- **Observaciones.** Se consideran tres diferentes maneras de observar
  los cambios de opiniones en el sistema.

  La primera es el cambio de color en los agentes de acuerdo a la
  opinión que tengan en ese momento, con valores entre $-1$ y $1$.
  Aquellos con valores cercanos a $-1$ tomarán un color más oscuro,
  mientras que aquellos con valores cercanos a $1$ tomarán colores más
  claros.

  El segundo resultado a observar es un histograma de las opiniones en
  todo el sistema, donde se observan picos alrededor de aquellas
  opiniones compartidas por una gran cantidad de agentes. Si estos se
  presentan en los dos extremos es una señal de polarización, mientras
  que en el consenso se espera ver solamente uno. Para la agrupación, se
  observan diversos picos distribuidos sobre todo el espacio de valores
  para la opinión.

  La última salida a observar es una gráfica donde la opinión de cada
  agente en un momento dado se representa como un punto. El eje $X$
  representa el tiempo o ticks, mientras que el eje $Y$ representa la
  opinión con valores entre $-1$ y $1$. Con suficiente tiempo se observa
  la convergencia de las opiniones a consenso, agrupación o
  polarización.

### Inicialización

El modelo se inicializa generando los agentes a utilizar en la
simulación. A continuación se les asignan opiniones aleatorias a cada
agente, tomando valores entre -1 y 1 siguiendo una distribución
uniforme, algo estándar en el área
[@galesicIntegratingSocialCognitive2021]. Por último se selecciona el
tipo de influencia a modelar, que se mantendrá fijo durante toda la
simulación.

### Datos de entrada

El modelo propuesto no necesita del uso de datos de entrada.

### Submodelos

- **Influencia positiva.** Para dos agentes $i$ y $j$ con opiniones
  $x_1, x_2$ respectivamente, su opinión se modifica después de una
  interacción mediante la siguiente fórmula $$\begin{align*}
          x_1 & \leftarrow x_1 + \gamma(x_2 - x_1) \\
          x_2 & \leftarrow x_1 + \gamma(x_1 - x_2)
  \end{align*}$$ donde $\gamma$ es un parámetro a ajustar en el modelo,
  indicando la fuerza de la influencia de otros agentes.

- **Confianza acotada.** Para dos agentes $i$ y $j$ con opiniones
  $x_1, x_2$ respectivamente, su opinión se modifica después de una
  interacción mediante la siguiente fórmula $$\begin{align*}
          x_1 & \leftarrow x_1 + \gamma(x_2 - x_1) \text{ si } |x_1 - x_2|<d\\
          x_2 & \leftarrow x_1 + \gamma(x_1 - x_2) \text{ si } |x_1 - x_2|<d.
  \end{align*}$$ El nuevo parámetro a considerar es $d$ o cota de
  confianza, indicando la tolerancia que tiene cada agente para
  opiniones disimilares.

- **Influencia negativa.** Para dos agentes $i$ y $j$ con opiniones
  $x_1, x_2$ respectivamente, su opinión se modifica después de una
  interacción mediante la siguiente fórmula $$\begin{align*}
          x_1 & \leftarrow 
          \begin{cases} 
          x_1 + \frac{\gamma}{2}(x_1 - x_2)(1-x_1), \text{ si } x_1 > x_2 \\
          x_1 + \frac{\gamma}{2}(x_1 - x_2)(1+x_1), \text{ en caso contrario } 
          \end{cases}
          \\
          x_2 & \leftarrow 
          \begin{cases} 
          x_2 + \frac{\gamma}{2}(x_2 - x_1)(1+x_2), \text{ si } x_1 > x_2 \\
          x_2 + \frac{\gamma}{2}(x_2 - x_1)(1-x_2), \text{ en caso contrario } 
          \end{cases}.
  \end{align*}$$
