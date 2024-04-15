using LinearAlgebra

n = 5 
x = rand(n) 
for i in 1:n 
    println(i)
end
# Same as:
for i in eachindex(x) 
    println(i)
end
# Different than:
for i in x 
    println(i) # "i" = x[i]
end

x = rand(5) 
acc = 0 
for i in eachindex(x) 
    acc += x[i] # = acc + x[i]
end
acc
sum(x)

x = rand(5) 
acc = 0 
for i in x
    acc += i # = acc + "i"
end
acc
sum(x)

z1 = rand(4)
z2 = rand(2)
z = (z1, z2)
k = 1
for i in z
    println(k)
    println(i)
    k += 1
end

Iterators.repeated(z, 4)

fz(x) = [p = p * 2 for p in x]
fz([1; 2; 3])

x = [1; 2; 3]
[p * 2 for p in x]

X = rand(5, 3)
foreach(normalize!, eachcol(X))
X
map(norm, eachcol(X))


