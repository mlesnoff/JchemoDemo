## Benchmark for computaion time 
## on PLSR

```julia
using Jchemo

```julia
n = 2000 ; p = 1000 
#n = 5000 ; p = 1000 
#n = 50000 ; p = 1000 
#n = 500000 ; p = 500 
#n = 10^6 ; p = 500 
q = 10 
X = rand(n, p)
Y = rand(n, q) 
y = Y[:, 1]
w = rand(n) ;
(n = n, p)

```julia
nlv = 25 
@time fm = plskern(X, Y; nlv = nlv) ;

```julia
@time fm = plskern!(X, Y; nlv = nlv) ;

