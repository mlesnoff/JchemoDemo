using JLD2, CairoMakie, FreqTables 
using Jchemo, JchemoData
using CodecZlib # requirede since the dataset is compressed 

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/mnist_20pcts.jld2") 

@load db dat
pnames(dat)
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

summ(vec(Xtrain)).res
summ(vec(Xtest)).res

plotsp(Xtest; nsamp = 1).f

nlv = 25
fm = plsqda(Xtrain, ytrain; nlv = nlv) ;
pred = Jchemo.predict(fm, Xtest).pred
err(pred, ytest)

freqtable(ytest, vec(pred))

cf = confusion(pred, ytest) ;
pnames(cf)
cf.cnt
cf.pct
cf.accuracy 

plotconf(cf).f
plotconf(cf; cnt = false).f
