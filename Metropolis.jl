using Plots
N = 0.05:0.1:0.95
M = 0.05:0.1:0.95

posiciones = [[i,j] for i in N, j in M]

θ = 2π*rand()
r = 0.045
δ = 0.001
t = 1
d = (δ*t*cos(θ), δ*t*sin(θ))

traslaciones = [[-1+i, -1+j] for i in 0:2, j in 0:2]

# Choose a disk 
pos = (rand(1:length(N)), rand(1:length(M)))

# Evolve disk 
new_place = posiciones[pos] .* d + posiciones[pos]
# See if valid 
if any(i -> norm(new_place, posiciones[p]) < 2r, posiciones)
    continue
else 
    posiciones[pos] = new_place
    # sacar el modulo porque se puede salir del cuadradao
end




