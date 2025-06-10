
using Jchemo, JchemoData
using JLD2, CairoMakie
using CodecZlib   # required since mnist20pct.jld2 is compressed


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/mnist20pct.jld2") 
@load db dat
@names dat


Xtrain = dat.Xtrain ;
ytrain = dat.ytrain ;
Xtest = dat.Xtest ;
ytest = dat.ytest ;
@head Xtrain
@head Xtest
ntrain, p = size(Xtrain) ;
ntest = nro(Xtest) ;
ntot = ntrain + ntest ;
(ntot = ntot, ntrain, ntest)


plotsp(Xtrain, 1:p; nsamp = 1, xlabel = "Pixel", ylabel = "Grey level (0-255)").f


tab(ytrain)
tab(ytest)

