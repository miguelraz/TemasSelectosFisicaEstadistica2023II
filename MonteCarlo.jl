#=
# # Monte-Carlo
# Como ya mencioné en la introducción, un algoritmo de Monte-Carlo es aquel que usa una cadena de Markov para las simulaciones. Una versión de esto es simplemente usar un generador de números aleatorios para producir un cálculo. 

# ## Integrales de Monte-Carlo
# Uno de los ejemplos mas famosos de un algoritmo de Monte-Carlo de este estilo es el obtener una integra usando un generador de números aleatorios. 
# Normalmente, para hacer una integral uno tiene que hacer una suma de Riemmann: 
∑(x) = sum(x)
∫(f, a, b; Δx=0.0001) = ∑([f(x) * Δx for x in a:Δx:b])


f(x) = asin(x^2)
using SymPy
@vars x
ex = f(x)
∫(f, 0, 1), integrate(ex, (x, 0, 1)).evalf()

# Si queremos hacer ahora una integral múltiple, por ejemplo: $\int_0^{10} \int_0^{10} \int_0^{10} \int_0^{10} f(x,y,z,w) dxdydzdw$,
# lo que tenemos que hacer es primero subdividir $\mathbb{R}^4$ en hipercubos de lado $\Delta x$ y hacer la suma de Rimman con conjuntos de 4D. Por ejemplo: 
∫_4d(f, a, b; Δx=0.01) = ∑(f(x, y, z, w) * Δx^4 for x in a[1]:Δx:b[1] for y in a[2]:Δx:b[2] for z in a[3]:Δx:b[3] for w in a[4]:Δx:b[4])

f(x, y, z, w) = x * y * cos(z) + sin(w) + 2

@time ∫_4d(f, [0, 0, 0, 0], [1, 1, 1, 1]), (1 / 4 * sin(1) + 1 - cos(1) + 2)

# Entonces, bajamos muchísimo la calidad de la integral (ahora es $\Delta x = 0.01$), pero subió mucho el tiempo de espera.
# La razón es simple, ahora tenemos una complejidad $O(n^4)$, donde $n$ es el número de divisiones de cada eje (o sea, el número de elementos en cada rango). 

# Para mejorar esto hay algunas técnicas, como la fórmula de Simpson generalizada, pero en ningún caso mejora sustancialmente.
# Las integrales usando sumas de Riemmann se vuelven extremadamente ineficientes en dimensiones altas. 

# Sin embargo, hay muchos cálculos en física que requieren de integrales múltiples.
# Por esta razón (y queriendo ganar una guerra de por medio), se trató de cambiar la forma de pensar sobre cómo resolver una integral múltiple.

# Esta nueva óptica sobre cómo resolver integrales múltiples vino de la probabilidad.
# Pensemos que dibujamos en el suelo una gráfica de una función, por ejemplo $x^2$. Como no podemos dibujarla con $x\in(-\infty, \infty)$,
# vamos a tener que acotar nuestra gráfica a una determinada región, por ejemplo, un cuadrado de tamaño $1\times 1$.
# Ahora lanzamos al aire un montón de granos de arena con pintura.
# Entonces, la probabilidad de que un grano de arena caiga bajo la curva $x^2$ dado que cayó
# en el cuadrado se puede aproximar usando la interpretación frecuentista de la probabilidad,
# es decir, contar cuántos granos cayeron bajo la curva y dividir eso entre el total de granos que cayeron en el cuadrado.
# Pero resulta que esa probabilidad es proporcional al área debajo de la curva dividido entre el área del cuadrado,
# o lo que es lo mismo, la integral bajo la curva se puede aproximar con la proporción entre número de granos y multiplicado eso por el área del cuadrado. 


using Plots

# Esta función es para graficar los disparos totales y los atinados en rojo y azul. 
function grafica_disparos(disparos_totales, disparos_atinados, área, lista_total, lista_atinados)
    scatter!([lista_total[k][1] for k in 1:disparos_totales], [lista_total[k][2] for k in 1:disparos_totales],
        markersize=1, markerstrokewidth=0, color=:red)
    scatter!([lista_atinados[k][1] for k in 1:disparos_atinados], [lista_atinados[k][2] for k in 1:disparos_atinados],
        markersize=1, markerstrokewidth=0, color=:blue)
    if mod(disparos_totales, 1) == 0
        annotate!([0.1], [0.8], text("Numero de disparos = $disparos_totales", :black, :left, 10))
        annotate!([0.1], [0.6], text("Puntos bajo la curva = $disparos_atinados", :black, :left, 10))
        annotate!([0.1], [0.4], text("Área = $(round(área*disparos_atinados/disparos_totales, digits = 4))", :black, :left, 10))
        plot!()
    end
end

f(x) = x^2  # función a la que se le calcula la integral.
x = 0:0.001:1  # rango de valores de la función. 
j = 0 # conteo de disparos atinados
disparos = 1000 #disparos totales
lista_de_puntos = [zeros(2) for i in 1:disparos]; #lista de puntos de los disparos
lista_de_disparos_atinados = [] #lista de puntos de los disparos atinados. No sé cuantos serán, así que dejo la lista vacía inicialmente. 
for i in 1:disparos
    point = rand(2)  #genero un disparo aleatorio
    plot(x, f.(x), key=false, aspect_ratio=1, xlim=(0, 1), ylim=(0, 1)) #grafico la función
    lista_de_puntos[i] = point # agrego el punto a la lista de disparos. 
    if point[2] < f(point[1]) #reviso si está bajo la curva.
        j += 1 #agrego el conteo
        push!(lista_de_disparos_atinados, point) #agrego el disparo a la lista de los atinados (esto sólo sirve para graficar)
    end
    grafica_disparos(i, j, 1, lista_de_puntos, lista_de_disparos_atinados) #grafico los puntos y la curva. 
end


# Como vemos aquí, el método no parece ser tan efectivo por varias razones. 
# 1. No se llega a un valor determinista, sino que se tiene una distribución de valores


"""
Función para integrar una función de R->R que se encuentre en el cuadrado formado por el intervalo x in [0,1] y y en el mismo 
intervalo. 
"""   # con este formato de comentario se hacen las instrucciones de una función
function integral(f, n)
    puntos = [rand(2) for i in 1:n]
    j = 0
    for i in 1:n
        if puntos[i][2] < f(puntos[i][1])
            j += 1
        end
    end
    return j / n
end

@time Areas = [integral(f, 1000) for i in 1:100001];

histogram(Areas, key=false, bins=100)


# 2. Es mucho más lento que la integral normal. Con los mismos 1000 pasos, la integral normal ya llegaba a un valor bastante razonable. 


t1 = @elapsed ∫(f, 0, 1; Δx=0.001)
t2 = @elapsed integral(f, 1000)
t2 / t1

# O sea, tarda 3 veces y media más y arroja un resultado mucho menos preciso que además es sólo probabilístico. No sabemos en realidad qué tan lejos estamos del resultado real. 

# y 

# 3. Requiero saber cuándo cuándo la integral es positiva y cuándo negativa, además de saber cuál es el mínimo y máximo de la función.

# Esto último no es para nada trivial, especialmente cuando se trata de un sistema de dimensiones altas. 

# Para encontrar el mínimo y el máximo uno puede obtener el gradiente y encontrar todos los puntos donde este gradiente se hace 0.
# No es algo fácil, pero se puede hacer siempre numéricamente al menos si la función no es demasiado oscilante,
# o el extremal no es demasiado picudo. Sobre el problema de saber cuánto la función es positiva y cuándo negativa habrá un problema en la tarea.  

# Sin embargo, a pesar de todos estos problemas, la eficiencia de este algoritmo aplicado a integrales múltiples no empeora, se mantiene. Esto significa que para dimensiones altas, el algoritmo sigue siendo razonable, mientras que los algoritmos basados en sumas de Riemmann se vuelven de complejidad $O(n^d)$, donde $n$ es el número de divisiones de cada eje y $d$ es la dimensión de la función. 


# Esta integral sólo sirve para funciones positivas en 4D, que se encuentran en intervalos en [a[i], b[i]], donde i va de 1 a 4
# y con un máximo menor a 5.
function ∫_monte_carlo(f, a, b; n=10000)
    X = [[rand() * (b[1] - a[1]) + a[1], rand() * (b[2] - a[2]) + a[2],
        rand() * (b[3] - a[3]) + a[3],
        rand() * (b[4] - a[4]) + a[4], rand() * 5] for i in 1:n]
    contador = 0
    for x in X
        if f(x[1:4]...) > x[5]
            contador += 1
        end
    end
    v = *((b .- a)...) * 5
    return v * contador / n
end
function ∫_monte_carlo2(f, a, b; n=10000)
    contador = 0
    for x in 1:n
        Base.Cartesian.@nexprs 4 i -> x_i = muladd(rand(), b[i] - a[i], a[i])
        contador += f(x_1, x_2, x_3, x_4) > rand() * 5
    end
    return (prod(b[i] - a[i] for i in 1:4) * 5) * contador / n
end

f(x, y, z, w) = x * y * cos(z) + sin(w) + 3
∫_monte_carlo(f, [0, 0, 0, 0], [1, 1, 1, 1]; n=1000), (1 / 4 * sin(1) + 1 - cos(1) + 2) #este es el valor analítico de la integral 
@time ∫_monte_carlo(f, [0, 0, 0, 0], [1, 1, 1, 1]; n=1000)
@time ∫_monte_carlo2(f, [0, 0, 0, 0], [1, 1, 1, 1]; n=1000)

#@btime ∫_monte_carlo($f,$[0,0,0,0],$[1,1,1,1]; n = 1000)
#@btime ∫_monte_carlo2($f,$[0,0,0,0],$[1,1,1,1]; n = 1000)

# Bastante impresionante, eh!

## Forma alternativa

# Una forma alternativa de hacer una integral de Monte-Carlo es vía el valor esperado (el promedio) $\langle X \rangle$ de una variable aleatoria $X$,
# pues este es:  $\int_{-\infty}^{\infty} \rho_X(x)dx$. 

# Por otro lado, al aplicar $g$ una función de $\mathbb{R} \rightarrow \mathbb{R}$, a una variable aleatoria $X$,
# obtenemos una nueva variable aleatoria $Y = g(X)$. El valor esperado de $Y$ $\langle Y \rangle$ es igual a $\int_{-\infty}^{\infty} g(x)\rho_X(x)dx$. 

# Este resultado es súper importante, pues si $X$ por ejemplo es una variable aleatoria uniforme entre $0$ y $1$,
# entonces $\rho_X(x) = 1$ si $x \in [0,1]$ y $0$ en cualquier otro caso. Por lo tanto $\langle g(X) \rangle = \int_0^1 g(x)dx$.
# Es decir, haciendo el promedio de $g(x)$ usando $x = rand()$, podemos calcular la integral entre $0$ y $1$ de $g(x)$!!!


∫01(g, n) = sum(g.(rand(n))) / n  #integral de 0 a 1 de g para cualquier función g!!

using SymPy
f(x) = x^2
@vars x
ex = f(x)
integrate(ex, (x, -5, 2)).evalf()

∫01(f, 1000), integrate(ex, (x, 0, 1)).evalf()

# Nuevamente, no es que el método sea increíblemente bueno, pero es importante el cambio de paradigma. 

# De tarea les voy a pedir calcular algunas integrales múltiples con todos los métodos.
# También les voy a pedir mostrar cómo se tendría que hacer la integral múltiple si no se hace en un intervalo unitario. 


# ## Ecuaciones diferenciales parciales. 

# Muchas ecuaciones diferenciales parciales se pueden interpretar como una ecuación probabilístic. Por ejemplo consideremos la ecuación de Laplace: 

# $$ \nabla^2 u  = 0$$ 

# Esta ecuación la queremos resolver con ciertas condiciones de frontera $u(x',y') = f(x',y')$ donde $f$ es una función conocida (ver figura).  

# Para interpretar la ecuación como un problema probabilístico, la escribimos en su forma en diferencias finitas (con la definición de derivada parcial). Es decir, 

# $$ \frac{u(x+\Delta, y) + u(x-\Delta, y) +u(x, y+\Delta) + u(x, y-\Delta) - 4 u(x,y)}{\Delta^2} = 0$$

# o bien: 

# $$u(x,y) =  \frac{u(x+\Delta, y) + u(x-\Delta, y) +u(x, y+\Delta) + u(x, y-\Delta) }{4}$$

# Esta forma de escribir la ecuación sugiere ver el plano $xy$ como una retícula con separación $\Delta$ entre un vértice de la retícula y sus vecinos (ver figura). 

# ![image-2.png](attachment:image-2.png)

# Ahora pensemos en partículas que se mueven sobre la red aleatoriamente de forma homogenea (caminantes aleatorios). Llamemos $u_0(x,y)$ la cantidad de partículas que hay en cada nodo de la red en el tiempo $t_0$. La cantidad de partículas en el tiempo $t_1$ en cada nodo será entonces en promedio: 

# $$\frac{u_0(x+\Delta, y) + u_0(x-\Delta, y) +u_0(x, y+\Delta) + u_0(x, y-\Delta) }{4}$$

# En el estado estacionario (si existe), se cumple que $u_n(x,y) = u_{n+1}(x,y)$ para todo par $(x,y)$. Por lo tanto, podemos pensar que la solución a la ecuación de Laplace se puede aproximar poniendo muchísimos caminantes aleatorios en la frontera con alguna probabilidad de ponerlos ahí (proporcional a $f(x',y')$) y revisando cuantos llegan al punto $(x,y)$, o equivalentemente, podemos poner muchas caminantes aleatorios en la posición $(x,y)$ inicialmente y esperar a que lleguen a la frontera. Dependiendo de a qué lugar de la forntera llegan, es el peso que tendrán en $(x,y)$. Es decir, $u(x,y)$ será un promedio pesado de las $u(x',y')$ de las fronteras a las que llegan las partículas. De hecho, directamente podemos aplicar la función $f$ obtieniendo: 

# $$ u(x,y) \sim \frac{1}{N} \sum f(x',y'),$$

# donde la suma se hace sobre los caminantes aleatorios. En este caso, la precisión de la solución depende de ambos, del tamaño de $\Delta$ (entre más pequeño, más fina la solución) y del número de caminantes aleatorios. 

# ### Código

# Para hacer nuestra simulación voy a tomar directamente una imagen que represente una placa que se está calentando (la de la imagen). 

# Con una imagen así resulta "fácil" definir las condiciones a la frontera. 
=#

#using Plots
using Images, Test
placa = load("placa.png");
# hagan su propio dibujo, sólo recuerden, la parte blanca no debe tocar las orillas 
# y es mejor que no exageren en el número de pixeles


### #<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAd8AAAFSCAYAAACzLtVeAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAADLFJREFUeAHtwQuS3MgVBMFIs3f/K6ckrMQVlxzOr7saKIT7FIokSVpmkCRJSw2SJGmpQffW8lQJ0tZanipB+xm0v5aXaflFgnRJLcu1vClB1zRoTy2n1fKLBOlUWk6v5YcEXcegPbRcWssPCdJLtFxWy08SdF6DrqtlSy0/SZCeomVbLT8k6FwGXUvL7bT8kCB9S8vttPyQoNcbdA0t+reWQ4L0KS36t5ZDgl5n0Hm16A0thwTpj1r0Gy0/JGitQefTog9q+SFBOrToE1oOCVpj0Hm06BtaDgm6qRZ9Q8shQc816PVa9EAthwTdRIseqOWQoOcY9FotepKWQ4I21aInajkk6LEGvUaLFmk5JGgjLVqkhQQ9zqD1WvQCLSTo4lr0Ai2HBH3foHVa9GIthwRdTItOoIUEfc+gNVp0Ii2HBJ1ci06m5ZCgrxn0XC06sRYSdFItOrEWEvR5g56nRRfQckjQibToAlpI0OcMeo4WXUwLCXqxFl1MCwn6uEGP1aILayFBL9Kii2o5JOh9gx6nRRtoOSRokRZtooUE/dmgx2jRZlpI0JO1aDMtJOhtg76vRZtqIUFP0qJNtZCg3xv0PS3aXMshQQ/Uos21kKBfDfq6Ft1ICwn6phbdSAsJ+tmgr2nRDbWQoC9q0Q21kKC/Dfq8Ft1YCwn6pBbdWAsJ+sugz2mRaCFBH9Qi0UKCYNDHtUg/tJCgd7RIP7SQcHeDPqZF+kULCXpDi/SLFhLubND7WqQ3tZCgf2iR3tRCwl0N+rMW6V0tJOi/WqR3tZBwR4Okx2gh4fZaJP3ZoLe1SJ/SQsJttUif0kLC3Qz6vRbpS1pIuJ0W6UtaSLiTQb9qkb6lhYTbaJG+pYWEuxgkPUcLCdtrkfQ5g37WIj1MCwnbapEepoWEOxj0txbp4VpI2E6L9HAtJOxukPR8LSRso0XS1w36S4v0VC0kXF6L9FQtJOxskLROCwmX1SIt0ULCrgZBiyRJqwx31yIt1ULC5bRIS7WQsKNB0notJFxGi6THGe6sRXqZFhJOr0V6mRYSdjNIep0WEk6rRdLjDXfVIkm6gBYSdjJIeq0WEk6nRdJzDHfUIp1KCwmn0SKdSgsJuxgkSdJSw920SKfUQsLLtUin1ELCDgZJ59FCwsu0SHq+4U5apNNrIUHSb7SQcHWDJP1Hi6Q1hrtokS6jhYRlWqTLaCHhygZJ59RCgqT9DJLurUXSWsMdtEiX1ELC07RIl9RCwlUNks6thQRJ+xgk3VOLpNcYdtciXV4LCQ/TIl1eCwlXNEiSpKUGSdfQQsK3tUh6rWFnLZKkjbWQcDWDpOtoIeHLWiS93iBJkpYadtUibamFhE9rkbbUQsKVDJKup4WED2uRdB6DJElaapB0TS0kvKtF0rkMkiRdXQsJVzHsqEW6hRYS3tQi6XwGSZK01CDp2lpI+EWLpHMaJEnSUsNuWqTbaSHhhxbpdlpIuIJBkiQtNUjaQwsJtEg6t0GSJC01SJKkpQZJ+2iRdH6DJElaapAkaRctJJzdsJMWSZLObpAkSUsNkiRpqUGSJC01SJKkpQZJkrTUIEmSlhokSdJSgyRJWmqQJElLDZIkaalBkiQtNUiSpKUGSZK01CBJkpYaJEnSUoMkSVpqkCRJSw2SJGmpQZIkLTVIkqSlBkmStNQgSZKWGiRJ0lKDJElaapAkSUsNkiRpqUGSJC017CSBFkmSzmyQJGkXCVcwSJKkpQZJkrTUIEmSlhokSdJSgyRJWmqQJElLDbtJoEWSdDMJVzFIkqSlBkmStNQgSZKWGiRJ0lKDJElaathRAi2SpJtIuJJBkiQtNUiSpKUGSZK01CBJkpYadpVAiyRpcwlXM0iSpKUGSZK01CBJkpYadpZAiyRpUwlXNEiSpKUGSZK01CBJkpYadpdAiyRpMwlXNUiSpKUGSZK01HAHCbRIknQGgyRJV5NwZYMkSVpqkCRJSw13kUCLJOniEq5ukCRJSw2SJGmp4U4SaJEkXVTCDgZJkrTUIEmSlhruJoEWSdLFJOxikCRJSw2SJGmp4Y4SaJEkXUTCTgZJkrTUIEmSlhruKoEWSdLJJexmkCRJSw13lkCLJOmkEnY0SJKkpQZJkrTUcHcJtEiSTiZhV4MkSVpqECTQIkk6iYSdDZIkaalBf0mgRZKkZxskSTqThN0NkiRpqUF/S6BFkvQiCXcwSJKkpQb9LIEWSdJiCXcxSJKkpQb9KoEWSdIiCXcySJKkpQb9XgItkqQnS7ibQZIkLTXobQm0SJKeJOGOBkmStNSgP0ugRZL0YAl3NUiSpKUGvS+BFknSgyTc2SBJkpYa9DEJtEiSvinh7gZJkrTUoI9LoEWS9EUJgkGSJC016HMSaJEkfVKC/jJIkqSlBn1eAi2SpA9K0N8GSZK01KCvSaBFkvSOBP1s0Ncl0CJJ0mcMkiQ9S4J+Neh7EmiRJP1Dgn5vkCRJSw36vgRaJEn/laC3DXqMBFok6fYS9GeDJElaatDjJNAiSbeVoPcNeqwEWiTpdhL0MYMkSVpq0OMl0CJJt5Ggjxv0HAm0SJL0T4MkSd+RoM8Z9DwJtEjSthL0eYMkSVpq0HMl0CJJ20nQ1wx6vgRaJGkbCfq6QZIkLTVojQRaJOnyEvQ9g9ZJoEWSLitB3zdIkqSlBq2VQIskXU6CHmPQegm0SNJlJOhxBr1GAi2SdHoJeqxBkiQtNeh1EmiRpNNK0OMNeq0EWiTpdBL0HINeL4EWSTqNBD3PIEmSlhp0Dgm0SNLLJei5Bp1HAi2S9DIJer5B55JAiyQtl6A1BkmStNSg80mgRZKWSdA6g84pgRZJeroErTXovBJokaSnSdB6gyRJWmrQuSXQIkkPl6DXGHR+CbRI0sMk6HUGXUMCLZL0bQl6rUHXkUCLJH1Zgl5v0LUk0CJJn5agcxh0PQm0SNKHJeg8BkmStNSga0qgRZLelaBzGXRdCbRI0psSdD6Dri2BFkn6RYLOadD1JdAiST8k6LwG7SGBFkkiQec2aB8JtEi6sQSd36C9JNAi6YYSdA2DJElaatB+EmiRdCMJuo5Be0qgRdINJOhaBu0rgRZJG0vQ9QzaWwItkjaUoGsatL8EWiRtJEHXNegeEmiRtIEEXdug+0igRdKFJej6Bt1LAi2SLihBexh0Pwm0SLqQBO1j0D0l0CLpAhK0l0H3lUCLpBNL0H4G3VsCLZJOKEF7GqQEWiSdSIL2NUj/kUCLpBNI0N4G6X8SaJH0Qgna3yD9vwRaJL1Agu5hkP4p4dAiaZEE3ccgvSWBFklPlKD7GaQ/SaBF0hMk6J4G6T0JtEh6oATd1yB9RAItkh4gQfc2SB+VQIukb0iQBukzEmiR9AUJ0n8M0mcl0CLpExKk/xmkr0igRdIHJEj/b5C+KuHQIuk3EqTfGaTvSqBF0v9JkN4ySI+QQIukf0uQ/mSQHiWBFunWEqT3DNIjJdAi3VKC9BGD9GgJhxbpFhKkzxikZ0mgRdpagvRZg/RMCbRIW0qQvmKQni2BFmkrCdJXDdIKCYcW6fISpO8YpJUSaJEuKUF6hEFaLYEW6VISpEcZpFdIoEW6hATpkQbpVRJokU4tQXq0QXqlhEOLdCoJ0rMM0hkk0CKdQoL0TIN0FgmHFullEqRnG6SzSaBFWipBWmWQziiBFmmJBGmlQTqrhEOL9BQJ0isM0tkl0CI9VIL0KoN0BQm0SA+RIL3SIF1FwqFF+pIE6QwG6WoSaJE+JUE6i0G6ogRapA9JkM5kkK4q4dAi/VaCdEaDdHUJtEg/SZDOapB2kHBo0c0lSGc3SDtJoEU3lSBdwSDtJuHQoptIkK5kkHaVQIs2lyBdzSDtLOHQos0kSFc1SHeQQIs2kSBd2SDdRcKhRReVIO1gkO4m4dCiC0mQdjFId5VAi04uQdrNIN1ZwqFFJ5Mg7WqQBAm06CQSpJ0Nkv6ScGjRiyRIdzBI+lnCoUWLJEh3Mkj6vQRa9GQJ0t0Mkt6WcGjRgyVIdzVIel/CoUXflCDd3SDp4xJo0RclSIJB0uckHFr0QQmS/jZI+pqEQ4vekCDpV4Ok70k4tOi/EiS9bZD0GAm03F6CpD8bJD1OwqHldhIkfcwg6fESDi3bS5D0OYOk50k4tGwnQdLXDJKeL+HQcnkJkr5nkLROwqHlchIkPcYgab2EQ8vpJUh6rEHS6yQcWk4nQdJzDJJeL4GW00iQ9DyDpHNI+KHlJRIkPd8g6XwSDi1PlyBprUHSeSUcWh4uQdJrDJLOL+HQ8m0Jkl5rkHQdCYeWT0uQdA6DpOtJOLS8K0HSuQySrivhh5YfEiSd1yBpDwmSrmGQJElL/QuPyRHA2vmaBgAAAABJRU5ErkJg">



n, m = size(placa)
@show n * m # una placa de 200mil pixeles es ya una placa grande. 
retícula = [placa[n+1-i, j] == placa[1, 1] ? -1 : 0 for i in 1:n, j in 1:m];  #vuelve la placa en una retícula de 0's y -1's
reticula2 = [placa[n+1-i, j] != first(placa) for i in 1:n, j in 1:m] |> BitArray;
#heatmap(retícula)
#heatmap(reticula2)

# La frontera son los pixeles (vértices de la red) que están en rojo y que son vecinos de un pixel blanco, o bien, en la retícula, son los elementos de la matriz que tienen como valor -1, pero que algún elemento vecino tiene como valor 0. 

# Para hacer la simulación el primer paso es comenzar un caminante en la zona adecuada. 


function posicion_permitida(i, j, retícula) #regresa true si la posición en la retícula es algo diferente de -1 y false en otro caso
    retícula[i, j] == -1 ? false : true
end

posicion_permitida2(i, j, reticula) = reticula[i, j]

@test !posicion_permitida2(1,1, reticula2)
@test posicion_permitida2(200, 150, reticula2)

# Con esta función podemos saber si nuestro caminante está en una posición permitida.

# Esta función la usamos tanto para revisar que inicialmente es un punto que debemos simular, como para checar si llegamos o no a la frontera. El siguiente paso es evolucionar al caminante. 


function evoluciona_caminante!(i, j, retícula)#mueve al caminante con igual probabilidad hacia arriba, abajo, izquierda o derecha.
    n = rand([[0, 1], [0, -1], [1, 0], [-1, 0]])
    i += n[1]
    j += n[2]
    return i, j
end

function evoluciona_caminante2!(i, j, reticula)#mueve al caminante con igual probabilidad hacia arriba, abajo, izquierda o derecha.
    n = rand(((0, 1), (0, -1), (1, 0), (-1, 0)))
    i += n[1]
    j += n[2]
    return i, j
end

@test evoluciona_caminante2!(2,2, reticula2) ∈ [(2,1), (1, 2), (3,2), (2, 3)]

function trayectoria_hasta_salir!(i, j, retícula) #genera la trayectoria desde el punto de partida, hasta llegar a la frontera (donde la retícula se vuelve -1)
    test = true
    I, J = [i], [j] # comienza la trayectoria en el punto de partida. 
    while test
        i, j = evoluciona_caminante!(i, j, retícula) #mueve al caminante
        push!(I, i), push!(J, j) #agrega la nueva posición a la trayectoria
        test = posicion_permitida(i, j, retícula) #revisa si llegó a la frontera
    end
    return I, J
end

# ~100μs, 200KiB-3.1MiB
#@btime trayectoria_hasta_salir!(100, 200, retícula);

function trayectoria_hasta_salir2!(i, j, retícula) #genera la trayectoria desde el punto de partida, hasta llegar a la frontera (donde la retícula se vuelve -1)
    IJ = [(i,j)] # comienza la trayectoria en el punto de partida. 
    sizehint!(IJ, 1024)
    while posicion_permitida2(i, j, retícula)
        i, j = evoluciona_caminante2!(i, j, retícula) #mueve al caminante
        push!(IJ, (i,j))
    end
    return IJ
end

function trayectoria_hasta_salir3!(i, j, mat)
    # comienza la trayectoria en el punto de partida. 
    IJ = PushVector{Tuple{eltype(i), eltype(j)}}([(i,j)]) 
    while posicion_permitida2(i, j, retícula)
        i, j = evoluciona_caminante2!(i, j, retícula) #mueve al caminante
        push!(IJ, (i,j))
    end
    finish!(IJ)
    return IJ
end

# ~5μs, 16kib
#@btime trayectoria_hasta_salir2!(100, 200, reticula2)
#@profview trayectoria_hasta_salir2!(200, 200, reticula2)

# Con estas funciones ya obtenemos para cada caminante en qué valor $(x',y')$ sale, pero de hecho tenemos más que eso, pues cada vértice por el que pasa es un lugar posible y todos ellos tienen esa trayectoria con esa salida. 

# Entonces, sólo necesitamos llevar una cuenta en cada parte de la retícula, de cuantos caminantes efectivos llevamos. Cuando todos los puntos superen un número $n$ de caminantes efectivos, podemos detener la simulación. 

# Para medir cuándo ya superamos ese mínimo, necesitamos primero que nada una función que encuentre dentro de la matriz el menor valor que sea mayor o igual a 0. 

function minimo_o_inf(matriz)
    n, m = size(matriz)
    x = typemax(Int)
    #busca el mínimo mayor o igual a 0. Si todos son negativos, regresa Inf
    for i in 1:n
        for j in 1:m  
            if matriz[i, j] < x && matriz[i, j] >= 0
                x = matriz[i, j]
            end
        end
    end
    return x
end

@test minimo_o_inf(retícula) == 0
@time minimo_o_inf(retícula)
# 
#@btime minimo_o_inf(retícula)

function minimo_o_inf2(matriz)
    n, m = size(matriz)
    x = typemax(Int)
    #busca el mínimo mayor o igual a 0. Si todos son negativos, regresa Inf
    for j in 1:m  
        for i in 1:n
            if matriz[i, j] < x && matriz[i, j] >= 0
                x = matriz[i, j]
            end
        end
    end
    return x
end

@test !minimo_o_inf2(reticula2)
@test minimo_o_inf(retícula) == Int(minimo_o_inf(reticula2))
@time !minimo_o_inf2(reticula2)
# 409 μs (0 allocs)
#@btime !minimo_o_inf2(reticula2)


function minimum_positivo(matriz) # revisa, entre los valores de la retícula que son mayores o iguales a 0, cual es el menor valor
    x = minimo_o_inf(matriz)
    if x ≠ Inf
        return x
    else
        return 0 # si todos los valores en la matriz son negativos, regresa 0. 
    end
end

function minimum_positivo2(matriz) # revisa, entre los valores de la retícula que son mayores o iguales a 0, cual es el menor valor
    x = minimo_o_inf2(matriz)
    if x ≠ typemax(Int)
        return x
    else
        return 0 # si todos los valores en la matriz son negativos, regresa 0. 
    end
end

function imprime_valores(i, j, numero_de_caminantes, contador, pasos)
    if mod(contador, pasos) == 0
        println("revisando vertice (", i, ", ", j, ")")
        println("numero maximo de caminantes = ", maximum(numero_de_caminantes))
        println("numero mínimo de caminantes = ", minimum_positivo(numero_de_caminantes))
        println()
        flush(stdout)
    end
end

function caminante!(i, j, retícula, f, solución, numero_de_caminantes)
    test = posicion_permitida(i, j, retícula) # revisa si el caminante está inicialmente en una posición permitida
    if test # si lo está entonces...
        x, y = trayectoria_hasta_salir!(i, j, retícula) #calcula su trayectoria
        s = f(x[end], y[end]) # calcula el peso
        for k in 1:length(x)-1
            solución[x[k], y[k]] += s #suma ese peso a la posición de todos los vértices por los que pasó.
            numero_de_caminantes[x[k], y[k]] += 1 # suma 1 a todos los vértices por los que pasó
        end
    end
    return solución, numero_de_caminantes
end

begin
    d1 = zeros(size(retícula));
    d2 = zeros(size(retícula));
    f(y, x) = 1 / (y + 1)
    @time caminante!(100, 200, retícula, f, d1, d2);
    # ~150μs, 3k allocs, 320KiB
    #@btime caminante!(100, 200, $retícula, $f, $d1, $d2);
end

# TODO asumir que me pasaron posicion permitida
function caminante2!(i, j, mat, f, solución, numero_de_caminantes)
    test = posicion_permitida2(i, j, mat)
    if test # si lo está entonces...
        xys = trayectoria_hasta_salir2!(i, j, mat) #calcula su trayectoria
        s = f(xys[end][1], xys[end][2]) # calcula el peso
        # TODO - use BLAS?
        for k in xys
            solución[CartesianIndex(k)] += s #suma ese peso a la posición de todos los vértices por los que pasó.
            numero_de_caminantes[CartesianIndex(k)] += 1 # suma 1 a todos los vértices por los que pasó
        end
    end
end

function caminante3!(i, j, mat, f, solución, numero_de_caminantes)
        xys = trayectoria_hasta_salir3!(i, j, mat) #calcula su trayectoria
        s = f(xys[end][1], xys[end][2]) # calcula el peso
        for k in xys
            solución[CartesianIndex(k)] += s #suma ese peso a la posición de todos los vértices por los que pasó.
            numero_de_caminantes[CartesianIndex(k)] += 1 # suma 1 a todos los vértices por los que pasó
        end
end

@time caminante2!(100, 200, reticula2, f, d1, d2);
#@profview caminante2!(100, 200, reticula2, f, d1, d2)
# ~7μs, 2 allocations, 16.14 KiB
#@btime caminante2!(100, 200, $reticula2, $f, $d1, $d2);
let 
    _sol = zeros(size(retícula));
    _num = zeros(size(retícula));
    @test sum(_sol) == 0
    @test sum(_num) == 0
    _a, _b = caminante!(100, 200, retícula, f, _sol, _num) 
    caminante2!(100, 200, reticula2, f, _sol, _num)
    @show(sum(_a))
    @show(sum(_b))
    @test (_sol, _num) == (_a, _b)
    @test sum(_sol) > 0
    @test sum(_num) > 0
end



function resuelve_Laplace(retícula, f, n)
    contador = 0
    n1, n2 = size(retícula)
    solución = zeros(n1, n2)
    numero_de_caminantes = [retícula[i, j] < 0 ? -1 : 0 for i in 1:n1, j in 1:n2] # asegura que la retícula sean sólo 0's y 1's
    outer_contador = 0
    while minimum_positivo(numero_de_caminantes) < n
        outer_contador += 1
        @show outer_contador
        for j in 1:n2, i in 1:n1
            contador += 1
            if contador % 5000 == 0
                @show contador 
                @show i j 
                @show n1 n2
            end
            #imprime_valores(i, j, numero_de_caminantes, contador, 5000) #imprime los valores cada 5000 pasos para saber qué tan avanzado va el cálculo
            solución, numero_de_caminantes = caminante!(i, j, retícula, f, solución, numero_de_caminantes)
            if minimum_positivo(numero_de_caminantes) > n
                break
            end
        end
    end
    return solución, numero_de_caminantes
end

# TODO - make an inside region mask 
# TODO - make a border region mask 
# TODO change `minimo_o_inf` to by `any` on the inside region
function encoger_reticula(reticula)
    left = findfirst(any.(>(0), eachcol(reticula)))
    right = findlast(any.(>(0), eachcol(reticula)))

    top = findfirst(any.(>(0), eachrow(reticula)))
    bot = findlast(any.(>(0), eachrow(reticula)))
    # TODO - handle corner cases where ±1 might not be inside the array
    reticula[top-1:bot+1, left-1:right+1]
end


shs = encoger_reticula(reticula2);
let 
    @test size(shs) == (335, 389)
    @test 2 == findfirst(any.(>(0), eachrow(shs)))
    @test 334 == findlast(any.(>(0), eachrow(shs)))
    @test 2 == findfirst(any.(>(0), eachcol(shs)))
    @test 388 == findlast(any.(>(0), eachcol(shs)))
    # TODO idempotencia shs == eng
    @test shs == encoger_reticula(shs)
end

# multiple inside regions may exist
function encontrar_frontera(m)
    frontera = falses(size(m))
    for (i, col) in enumerate(eachcol(m))
        frontera[:, i] .|= @views circshift(m[:, i], 1) .⊻ circshift(m[:, i], -1)
    end 
    for (j, row) in enumerate(eachrow(m))
        frontera[j, :] .|= @views circshift(m[j, :], 1) .⊻ circshift(m[j, :], -1)
    end
    frontera
end

@test [0 1 0; 1 0 1; 0 1 0] == encontrar_frontera([0 0 0; 0 1 0; 0 0 0])

f(y, x) = 1 / (y + 1)
# INPUT: 
# mat - BitMatrix de puntos interiores
function resuelve_Laplace2(mat, f, n)
    mat = encoger_reticula(mat)
    n1, n2 = size(mat)
    sol = zeros(Float64, (n1, n2))
    numero_de_caminantes = zeros(UInt32, (n1, n2))
    # TODO - reuse a single pushed_vector buffer
    # setup PushVector{(T,T)}() 
    while all(<(n), numero_de_caminantes[mat])
        for j in 1:n2
            for i in 1:n1
                caminante2!(i, j, mat, f, sol, numero_de_caminantes)
            end
            all(>=(n), numero_de_caminantes[mat]) && break
        end
    end
    @show maximum(numero_de_caminantes) |> Int
    return sol, numero_de_caminantes
end


# TODO - shrink region of interest 

# ### WARNING - muy tardado
# 285s, 4.1G allocations, 338 GiB
#@time resuelve_Laplace(retícula, f, 2)
#@test retícula == reticula2 .+ (-1)
#using Profile
@time sol, num = resuelve_Laplace2(reticula2, f, 2);

@show maximum(numero_de_caminantes), minimum_positivo(numero_de_caminantes)

function mezcla_solucion_n(s, nc)  # Esta función simplemente sirve para hacer los promedios de la solución correctamente. 
    n, m = size(s)
    [nc[i, j] > 0 ? s[i, j] / nc[i, j] : NaN for i in 1:n, j in 1:m]
end
ss = mezcla_solucion_n(solución, numero_de_caminantes);

heatp = heatmap(numero_de_caminantes, aspect_ratio=:equal)
heatT = heatmap(ss, aspect_ratio=:equal)
plot(heatT, heatp)


# Esto lo hace bien, pero como los caminantes no visitan parejo todos los vértices, donde se tinen pocas visitas se podría pensar que el ruido será mayor. 

# Una forma de muestrear más homogeneamente, es elegir aleatoriamente el vértice de inicio sólo entre los vértices que hayan sido visitado menos. Es decir, tomar todos los vértices cuyo número de visitas sea igual al número mínimo de visitas, excluyendo los vértices que no pueden ser visitados. 

# Para esto primero necesitamos definir una función que encuentre todos los mínimos que sean mayores o iguales a 0: 


# a partir de aquí ya no arreglé las funciones, así que van a estar un poco más feas... Lo siento! 
function minimos_positivos(matriz)
    y = minimum_positivo(matriz)
    I = findall(x -> x == y, matriz)
end

minimos_positivos2(matriz) = findall(==(minimum_positivo(matrix)), matriz)

function minimos_positivos(matriz, mini)
    I = findall(x -> x == mini, matriz)
end

minimos_positivos2(matriz, mini) = findall(==(mini), matriz)

function resuelve_Laplace_h(retícula, f, n)
    contador = 0
    n1, n2 = size(retícula)
    solución = zeros(n1, n2)
    numero_de_caminantes = [retícula[i, j] < 0 ? -1 : 0 for i in 1:n1, j in 1:n2]
    mini = 0
    I = minimos_positivos(numero_de_caminantes)
    while minimum_positivo(numero_de_caminantes) < n + 1
        if mini == 0 && contador > 0
            I = minimos_positivos(numero_de_caminantes)
            mini = numero_de_caminantes[I[1]]
        elseif mini > 0
            I = minimos_positivos(numero_de_caminantes, mini)
            if length(I) == 0
                I = minimos_positivos(numero_de_caminantes)
            end
            mini = numero_de_caminantes[I[1]]
        end
        j = rand(I)
        contador += 1
        imprime_valores(j[1], j[2], numero_de_caminantes, contador, 5000)
        test = posicion_permitida(j[1], j[2], retícula)
        if test
            x, y = trayectoria_hasta_salir!(j[1], j[2], retícula)
            s = f(x[end], y[end])
            for k in 1:length(x)-1
                solución[x[k], y[k]] += s
                numero_de_caminantes[x[k], y[k]] += 1
            end
        end

    end
    return solución, numero_de_caminantes
end

load("placa2.png")

dg = load("placa3.png")

n, m = size(dg)
@show n, m
retícula = [Float64(dg[i, j].r) + Float64(dg[i, j].g) + Float64(dg[i, j].b) < 2 ? -1 : 0 for i in 1:n, j in 1:m];

heatmap(retícula, aspect_ratio=:equal)

f(x, y) = 100 / (1 + (x - 200)^2 + (y - 120)^2)

@time solución, numero_de_caminantes = resuelve_Laplace_h(retícula, f, 10)

@time solución2, numero_de_caminantes2 = resuelve_Laplace(retícula, f, 10)

s_dg = mezcla_solucion_n(solución, numero_de_caminantes);
s_dg2 = mezcla_solucion_n(solución2, numero_de_caminantes2);

n, m = size(s_dg)
s_dgf = [s_dg[i, j] == 0 ? f(i, j) : s_dg[i, j] for i in 1:n, j in 1:m]
s_dgf2 = [s_dg2[i, j] == 0 ? f(i, j) : s_dg2[i, j] for i in 1:n, j in 1:m];

heat_pdg = heatmap(numero_de_caminantes, aspect_ratio=:equal)
heat_Tdg = heatmap(s_dgf, aspect_ratio=:equal)
plot(heat_pdg, heat_Tdg)

heat_pdg2 = heatmap(numero_de_caminantes2, aspect_ratio=:equal)
heat_Tdg2 = heatmap(s_dgf2, aspect_ratio=:equal)
plot(heat_pdg2, heat_Tdg2)


# Como se ve, de hecho es más rápido y mejor el método donde dejamos que los muestreos no sean parejos. La razón es que en realidad donde hay pocas visitas, es porque la probabilidad de caer en un conjunto pequeño de lugares de la frontera es muy alto, por lo que al hacer el promedio, en realidad no requerimos un muestreo tan grande. En cambio, los vértices que tienen una probabilidad casi homogenea de caer en cualquier lugar de la frontera tienen fluctuaciones mucho mayores y por lo tanto requieren un muestreo mayor para reducir esas fluctuaciones. 

