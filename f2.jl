using Pkg
pkg"activate ."
pkg"add JuMP"
pkg"add Cbc"
pkg"add Juniper"
pkg"add Ipopt"

using JuMP, Cbc, Juniper
# Escolhendo o modelo
model = Model(Cbc.Optimizer)
# Definindo os parâmetros que, por sinal, coloquei aleatórios, pois não sei as entradas
m = 4
n = 4
c = rand(1:4, n,m)
a = rand(0:0, m)
b = rand(1000:1000,n)

# Implementando realmente o modelo
@variable(model,x[ i = 1:n, g = 1:m], Bin) # Variáveis
@variable(model,y[i = 1:n,j = 1:n,g = 1:m], Bin) #Variáveis

#Func. objetivo
@objective(model, Max, sum(c[i,j] * y[i,j,g] for i = 1:n-1, j = i+1:n, g = 1:m))   

#Restrições
@constraint(model, [i = 1:n], sum(x[i,g] for g = 1:m) == 1)
@constraint(model, [i = 1:n, g = 1:m], sum(x[i,g] for g = 1:m) ≤ b[g])
@constraint(model, [i = 1:n, g = 1:m], a[g] <= sum(x[i,g] for g = 1:m))
@constraint(model,[i = 1:n-1, j = i+1:n, g = 1:m;1 ≤ i < j ≤ n], y[i,j,g] <= x[i,g])
@constraint(model, [i = 1:n-1, j = i+1:n, g = 1:m;1 ≤ i < j ≤ n], y[i,j,g] <= x[j,g])
@constraint(model, [i = 1:n-1, j = i+1:n, g = 1:m;1 ≤ i < j ≤ n], y[i,j,g] ≥ x[i,g] + x[j,g] - 1)

optimize!(model) # Otimizando o modelo

println("Valor da função objetivo = ", objective_value(model))
value.(x)