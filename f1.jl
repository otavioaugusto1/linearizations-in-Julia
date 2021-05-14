using Pkg
pkg"activate ."
pkg"add JuMP"
pkg"add Cbc"
pkg"add Juniper"
pkg"add Ipopt"

using JuMP, Ipopt, Juniper

# Escolhendo o modelo
optimizer = Juniper.Optimizer
nl_solver = optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0)
model = Model(optimizer_with_attributes(optimizer, "nl_solver" => nl_solver))

# Definindo os parâmetros que, por sinal, coloquei aleatórios, pois não sei as entradas
m = 4   
n = 4
c = rand(1:4, n,m)
a = rand(0:0, m)
b = rand(1000:1000,n)

# Implementando realmente o modelo
@variable(model, x[i = 1:n, g = 1:m], Bin) #Variável
@NLobjective(model, Max, sum(c[i,j] * x[i,g] * x[j,g] for i = 1:n-1, j = i+1:n, g = 1:m)) #Func. objetivo

#Restrições
@constraint(model, [i = 1:n], sum(x[i,g] for g = 1:m) == 1)
@constraint(model, [i = 1:n, g = 1:m], sum(x[i,g] for g = 1:m) ≤ b[g])
@constraint(model, [i = 1:n, g = 1:m], a[g] <= sum(x[i,g] for g = 1:m))

optimize!(model) # Otimizando o modelo

println("Valor da função objetivo = ", objective_value(model))
round.(value.(x))