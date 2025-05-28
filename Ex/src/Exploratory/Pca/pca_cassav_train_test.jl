
using Jchemo, JchemoData
using JLD2, CairoMakie, GLMakie


using JchemoData, JLD2, CairoMakie, GLMakie
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/cassav.jld2")
@load db dat
@names dat


X = dat.X 
Y = dat.Y 
year = Y.year 
tab(year)


s = year .<= 2012
Xtrain = X[s, :]
Xtest = rmrow(X, s)
ntrain = nro(Xtrain) 
ntest = nro(Xtest)


model = pcasvd(nlv = 10) 
fit!(model, Xtrain)  
fitm = model.fitm ; 
@head Ttrain = fitm.T


@head Ttest = transf(model, Xtest)


CairoMakie.activate!()
T = vcat(Ttrain, Ttest) ;  
group = [repeat(["Train"], ntrain); repeat(["Test"], ntest)] ;
plotxy(T[:, 1], T[:, 2], group; zeros = true, xlabel = "PC1", ylabel = "PC2").f


color = [(:red, .5), (:blue, .5)]
plotlv(T[:, 1:6], group; size = (750, 400), shape = (2, 3), color = color, zeros = true, xlabel = "PC", ylabel = "PC").f


CairoMakie.activate!()  
#GLMakie.activate!()    # for interactive axe-rotation

i = 1
size = (600, 350)
plotxyz(T[:, i], T[:, i + 1], T[:, i + 2], group; size, color, markersize = 10, 
    xlabel = string("PC", i), ylabel = string("PC", i + 1), zlabel = string("PC", i + 2), 
    title = "Pca score space").f

