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
m = 4 # linha
n = 4 # coluna
c = rand(1:4, n,m) #matriz
# l,c = size(c)
a = rand(0:0, m) 
b = rand(1000:1000,n)
lb = [5,4] #limites inferiores
ob = [6,5] # limites superiores
# Implementando realmente o modelo
@variable(model,w[i = 1:n-1, g = 1:m], Bin) #Variável
@variable(model,x[i = 1:n, g = 1:m], Bin) #Variável
@objective(model, Max, sum(w[i,g] for g = 1:m, i = 1:n-1)) #Func. objetivo

#Restrições
@constraint(model, [i = 1:n, g = 1:m], sum(x[i,g] for i = 1:n-1, g = 1:m) == 1) # 1º restrição
@constraint(model, [i = 1:n, g = 1:m], sum(x[i,g] for i = 1:n-1, g = 1:m ) ≤ b[g]) # 2º restrição
@constraint(model, [i = 1:n, g = 1:m], sum(x[i,g] for i = 1:n-1, g = 1:m ) ≥ a[g]) # 3º restrição
@constraint(model, [i = 1:n - 1, g = 1:m], - sum(max(0,(c[i,j])) * x[i,g] + w[i,g] for j = i+1:n) <= 0) # 4º restrição
@constraint(model, [i = 1:n - 1, g = 1:m], - sum(c[i,j]*x[j,g] for j = i+1:n) +  sum(min(0,c[i,j]) * (1 - x[i,g]) for j = i+1:n)+ w[i,g] <= 0) # 5º restrição

optimize!(model) # Otimizando o modelo

println("Valor da função objetivo = ", objective_value(model))
value.(x)