using Random, Distributions, StatsBase

rand(5)
rand(5, 3)

rand(1:3, 10)
rand([.3 ; 12 ; .8], 5)

randn(5)

rand(MersenneTwister(1), 1:3, 4)
rand(MersenneTwister(1), 1:3, 4)

X = zeros(5, 3)
rand!(X) ;
X

rand(Uniform(-20, 20), 10)

probs = [0.3, 0.3, 0.2, 0.15, 0.05]
mnd = Multinomial(10, probs)
rand(mnd)

probs = [0.3, 0.3, 0.2, 0.15, 0.05]
items = 1:length(probs) #[i for i in 1:length(probs)]
weights = Weights(probabilities)
for i in 1:20
    println(sample(items, weights))
end

# Inspired from 
# https://discourse.julialang.org/t/sampling-without-replacement/1073/3
# Shorty66
function sample_wr!(x, n)
    n = min(n, length(x))
    s = similar(x, n)
    @inbounds for i = 1:n
        u = rand(eachindex(x))      
        s[i] = splice!(x, u)
    end
    s
end
z = [1 ; 2; 21.1 ; 5 ; 32]
sample_wr!(z, 3)
z

#### Sampling without replacement

sample(1:10, 5; replace = false)
sample(MersenneTwister(1), 1:10, 5; replace = false)
sample(1:10, 5; replace = false, ordered = true)
sample!(1:10, Vector{Int}(undef, 5); replace = false)

rep = 3
for i = 1:rep
    s = sample(MersenneTwister(2), 1:10, 5; replace = false)
    println(s)
end

z = [1 ; 8; 4.]
probs = [0, 0, 1] 
sample(z, Weights(probs), 2)

n = 10^6 ; x = collect(1:n) ;
@time sample(1:n, 100, replace = false) ;  #### Good one
@time sample!(1:n, Vector{Int}(undef, 100), replace = false) ; ## Same

## Much slower since inefficient ways
@btime sample_wr!(collect(1:n), 100) ; # Slower
@btime randperm(n)[1:100] ;
@btime randperm!(Vector{Int}(undef, n))[1:100] ;
@btime shuffle(collect(1:n))[1:100] ;
@btime shuffle!(collect(1:n))[1:100] ;
## Even more slower
@btime sample(1:n, n, replace = false)[1:100] ;
@btime sample!(1:n, Vector{Int}(undef, n), replace = false)[1:100] ;

##### Permutations

randperm(5)
randperm!(MersenneTwister(1234), Vector{Int}(undef, 5))

x = collect(1:5)
shuffle(x)

y = copy(x)
shuffle!(y) ;
y

n = 10^4 
@time randperm(n) ;
@time shuffle(1:n) ; ## Little slower, since can permute any vector

n = 10^5
x = collect(1:n) 
@time randperm(n) ; ## Good one
@time sample(x, n, replace = false) ;
@time shuffle(x)

https://stackoverflow.com/questions/27559958/how-do-i-select-a-random-item-from-a-weighted-array-in-julia

