using JLD2, CairoMakie, FreqTables 
using Jchemo, JchemoData
using CodecZlib # required since the dataset is compressed 

```julia
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/mnist_20pcts.jld2") 
@load db dat
pnames(dat)

```julia
Xtrain = dat.Xtrain
ytrain = dat.ytrain
Xtest = dat.Xtest
ytest = dat.ytest
Xtrain = Matrix(Xtrain) / 255
Xtest = Matrix(Xtest) / 255
ntrain, p = size(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)  

```julia
summ(vec(Xtrain)).res

```julia
summ(vec(Xtest)).res

```julia
plotsp(Xtest; nsamp = 1).f

```julia
nlv = 25
fm = plsqda(Xtrain, ytrain; nlv = nlv) ;
pred = Jchemo.predict(fm, Xtest).pred
err(pred, ytest)

```julia
freqtable(ytest, vec(pred))

```julia
cf = confusion(pred, ytest) ;
pnames(cf)

```julia
cf.cnt

```julia
cf.pct

```julia
cf.accuracy 

```julia
plotconf(cf).f

```julia
plotconf(cf; cnt = false).f
