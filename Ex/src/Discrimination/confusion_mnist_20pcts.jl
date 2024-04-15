
using JLD2, CairoMakie, FreqTables 
using Jchemo, JchemoData
using CodecZlib # required since the dataset is compressed


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


mod = model(plsqda(nlv = 25)
fit!(mod, Xtrain, ytrain)
pred = predict(mod, Xtest).pred
errp(pred, ytest)  # overall
merrp(pred, ytest) # average by class


freqtable(ytest, vec(pred))


cf = conf(pred, ytest) ;
pnames(cf)


cf.cnt


cf.pct


cf.diagpct


cf.accpct


plotconf(cf).f


plotconf(cf; cnt = false).f

