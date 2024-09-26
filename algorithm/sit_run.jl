using Revise
using Pkg
Pkg.activate("../sit_atbd_env_jl")
includet("CIMR_IO_tools.jl") #mainly for the python exe paths setting 
includet("sitalgorithm.jl")
using Dates
using NCDatasets
using Printf
using PythonCall
pr = pyimport("pyresample")
np = pyimport("numpy")
basemap = pyimport("mpl_toolkits.basemap")



"""
function to store the output of the algorithm in a netcdf file
alldata is a namedtuple containing forward and backward data,
    each consisting of data, err, lat, lon
    data is a 1d array of size (npoints) containing the sea ice thickness
    err is a 1d array of size (npoints) containing the error
    lat is a 1d array containing the latitude
    lon is a 1d array containing the longitude
    its is a 1d array containing the number of iterations #not used yet
grid is a string containing the name of the grid used for the data
"""
function store_output(outfn, alldata, grid)
    @assert grid in ["native", "ease2_nh", "ease2_sh"]
    # both ease2 grids are the center cut out original 9000km x 9000k grid, i.e., 4500x4500km
    # if ease2 is selected then resample accordingly
       
    if grid == "ease2_nh"
        ad=pr.geometry.AreaDefinition("ease2_nh", "ease2_nh", "ease2_nh", "EPSG:6931", 1440,1440, [-9.0e6, -9.0e6, 9.0e6, 9.0e6])
    elseif grid == "ease2_sh"
        ad=pr.geometry.AreaDefinition("ease2_sh", "ease2_sh", "ease2_sh", "EPSG:6932", 1440, 1440, [-9.0e6, -9.0e6, 9.0e6, 9.0e6])
    end

    standard_names = ["sea_ice_thickness", "sea_ice_thickness standard_error","sea_ice_thickness quality_flag"]
    units = ["m", "m", "1"]
    longnames = ["Sea Ice Thickness", "Sea Ice Thickness Standard Error", "Sea Ice Thickness Quality Flag"]


    # create the output file
    NCDataset(outfn, "c") do ncid
        ds = (;forward = defGroup(ncid,"forward"),
        backward = defGroup(ncid,"backward"),
        combined = defGroup(ncid,"combined"))

        # create the dimensions
        if grid == "native"
            defDim(ncid, "npoints", length(lat))
            latid = defVar(ncid,"lat", lat, ("npoints",),deflatelevel=5, shuffle=true, chunksizes=(length(lat),))

            lonid = defVar(ncid,"lon", lon, ("npoints",),deflatelevel=5, shuffle=true, chunksizes=(length(lon),))
        else
            xsize=pyconvert(Int,ad.x_size)
            ysize=pyconvert(Int,ad.y_size)
            defDim(ncid, "x", xsize)
            defDim(ncid, "y", ysize)
            lons,lats=ad.get_lonlats()
            x,y=ad.get_proj_vectors()
            @show xsize,ysize,length(x),length(y)
            defVar(ncid, "x" , pyconvert(Array{Int},x), ("x",),deflatelevel=5, shuffle=true, chunksizes=(xsize,), attrib=Dict("units"=>"m", "standard_name"=>"projection_x_coordinate"))
            defVar(ncid, "y", pyconvert(Array{Int},y), ("y",),deflatelevel=5, shuffle=true, chunksizes=(ysize,), attrib=Dict("units"=>"m", "standard_name"=>"projection_y_coordinate`"))
            latid = defVar(ncid,"lat", pyconvert(Array, lats)', ("x", "y"),deflatelevel=5, shuffle=true, chunksizes=(xsize,ysize), attrib=Dict("units"=>"degrees_north", "standard_name"=>"latitude","grid_mapping"=>"crs"))
            lonid = defVar(ncid,"lon", pyconvert(Array, lons)', ("x", "y"),deflatelevel=5, shuffle=true, chunksizes=(xsize,ysize), attrib=Dict("units"=>"degrees_east", "standard_name"=>"longitude","grid_mapping"=>"crs"))
        end


        # add data variables


        # add projection information
        cfdict=pyconvert(Dict,ad.to_cartopy_crs().to_cf())
        defVar(ncid, "crs", 1,() , attrib=cfdict)
        alldata=Dict("forward"=>alldata.forward, "backward"=>alldata.backward, "combined"=> let f=alldata.forward, b=alldata.backward
            (;ssit=[f.ssit;b.ssit],
            sit_error=[f.sit_error;b.sit_error], 
            lat=[f.lat;b.lat], 
            lon=[f.lon;b.lon])
        end
        )
        #resampled and stored in group is the output file
        for dir in ("forward","backward","combined")
            datablock=alldata[dir].ssit
            #clamping to 0 - 200 cm for the SIT to avoid unrealistic values
            datablock[datablock.>200.0] .= 200.0
            datablock[datablock.<0.0] .= 0.0

            errblock=alldata[dir].sit_error
            #clamping to 0 - 200 cm for the SIT error to avoid unrealistic values
            errblock[errblock.>200.0] .= 200.0
            errblock[errblock.<0.0] .= 0.0  



            lat=alldata[dir].lat
            lon=alldata[dir].lon
            #calculate the flag, bit 1 is set for nominal, bit 2 for over land, bit 3 for ice free, bit 4 for 50cm
            flag = zeros(Int64,size(datablock))
            flag[datablock.<150.0] .|= 1 #bit 1, <150 is nominal
            land = basemap.maskoceans(lon, lat, lat).mask |> x->.~(pyconvert(Array,x))
            flag[land] .|= 2 #bit 2, over land
            flag[datablock.<1.0] .|= 4 #bit 3
            flag[datablock.>50.0] .|= 8 #bit 4

            npblock=np.array(datablock, dtype=np.float32)
            nperrblock=np.array(errblock, dtype=np.float32)
            npflagblock=np.array(flag, dtype=np.int64)
            in_ad=pr.geometry.SwathDefinition(lons=lon, lats=lat)
            npblockresampled=pr.kd_tree.resample_nearest(in_ad, npblock, ad, radius_of_influence=36000, fill_value=NaN) |> x -> pyconvert(Array, x)
            nperrblockresampled=pr.kd_tree.resample_nearest(in_ad, nperrblock, ad, radius_of_influence=36000, fill_value=NaN) |> x -> pyconvert(Array, x)
            flagblockresampled=pr.kd_tree.resample_nearest(in_ad, npflagblock, ad, radius_of_influence=36000, fill_value=0) |> x -> pyconvert(Array, x)

            if grid == "native"
                defVar(getfield(ds, Symbol(dir)) , standard_names[1], 
                Float64, ("npoints",), attrib=Dict("standard_name"=>standard_names[1], "units"=>units[1], "long_name"=>longnames[1]), deflatelevel=5, shuffle=true, chunksizes=(length(lat),))[:]=npblockresampled[:]
                defVar(getfield(ds, Symbol(dir)) , standard_names[2], Float64, ("npoints",) , attrib=Dict("standard_name"=>standard_names[2], "units"=>units[2], "long_name"=>longnames[2]), deflatelevel=5, shuffle=true, chunksizes=(length(lat),))[:]=nperrblockresampled[:]
                defVar(getfield(ds, Symbol(dir)) , standard_names[3], 
                Float64, ("npoints",), attrib=Dict("standard_name"=>standard_names[3], "units"=>units[3], "long_name"=>longnames[3]), deflatelevel=5, shuffle=true, chunksizes=(length(lat),))[:]=npblockresampled[:]
            else
                defVar(getfield(ds, Symbol(dir)) , standard_names[1],
                Float64 , ("x", "y"), attrib=Dict("standard_name"=>standard_names[1], "units"=>units[1], "long_name"=>longnames[1],"grid_mapping"=>"crs"), deflatelevel=5, shuffle=true, chunksizes=(xsize,ysize))[:]=npblockresampled[:,:]'
                defVar(getfield(ds, Symbol(dir)) , standard_names[2], Float64, ("x","y"),attrib=Dict("standard_name"=>standard_names[2], "units"=>units[2], "long_name"=>longnames[2],"grid_mapping"=>"crs"), deflatelevel=5, shuffle=true, chunksizes=(xsize,ysize))[:] = nperrblockresampled[:,:]'
                defVar(getfield(ds, Symbol(dir)) , standard_names[3],
                Int64 , ("x", "y"), attrib=Dict("standard_name"=>standard_names[3], "units"=>units[3], "long_name"=>longnames[3],"grid_mapping"=>"crs"), deflatelevel=5, shuffle=true, chunksizes=(xsize,ysize))[:]=flagblockresampled[:,:]'
            end
        end

        # add metadata
        ncid.attrib["project"]="ESA CIMR DEVALGO (contract 4000137493)"
        ncid.attrib["project_lead"]="Thomas Lavergne"
        ncid.attrib["project_lead_email"]="thomas.lavergne@met.no"
        ncid.attrib["date_created"]=Dates.now() |> string
        ncid.attrib["processing_level"]="Level-2"
        ncid.attrib["standard_name_vocabulary"]="CF Standard Name Table (Version 83, 17 October 2023)"
        ncid.attrib["spacecraft"]="CIMR"
        ncid.attrib["instrument"]="CIMR"
        ncid.attrib["product_level"]="2"
        ncid.attrib["product_name"]="sea ice thickness retrieval"
        ncid.attrib["variable_list"]="sea_ice_thickness, sea_ice_thickness standard_error, sea_ice_thickness quality_flag"
        ncid.attrib["product_version"]="0.1"
        ncid.attrib["author"]="Marcus Huntemann"
        ncid.attrib["author_email"]="macrus.huntemann@uni-bremen.de"
    end
    nothing
end

function get_the_data(fn,dir;kwargs...)
    if dir in ["forward","backward"]
            (;h,v,lat,lon)=get_data_for_band(fn,"L_BAND", dir;kwargs...)
            ssit,sit_error=comb_error_2.(h,v) |> x->(first.(x),last.(x))
            (;h,v,lat,lon,ssit,sit_error)
    elseif dir=="combined"
            fw=get_data_for_band(fn,"L_BAND", "forward";kwargs...)
            bw=get_data_for_band(fn,"L_BAND", "backward";kwargs...)
            h = [fw.h; bw.h]
            v = [fw.v; bw.v]
            lat = [fw.lat; bw.lat]
            lon = [fw.lon; bw.lon]
            ssit,sit_error=comb_error_2.(h,v) |> x->(first.(x),last.(x))
            (;h,v,lat,lon,ssit,sit_error)
   end
end

function prepare_data(fn,kwargs...)
    #stores the data for all three direction in a named tuple
    alldirs=("forward","backward","combined")


    alldata=NamedTuple{Symbol.(alldirs)}(get_the_data.(Ref(fn),alldirs))
    return alldata
end


inpath = get(ENV, "DEVALGO_INPUT_DATA_PATH", "/mnt/spaces/Projects/2022_CIMR-DEVALGO/DATA")
println(inpath)

if isempty(ARGS)
    fn=joinpath(inpath,"SCEPS/SCEPS_l1b_sceps_geo_polar_scene_1_unfiltered_tot_minimal_nom_nedt_apc_tot_v2p1.nc")
else
    fn = ARGS[1]
    @assert isfile(fn)
end

if length(ARGS) < 2
   outfn = "out_polar.nc"
else
    outfn = ARGS[2]
end

if length(ARGS) < 3
    outgrid = "ease2_nh"
else
    outgrid = ARGS[3]
    @assert outgrid in ["ease2_nh", "ease2_sh"]
end

alldata = prepare_data(fn) 

store_output(outfn, alldata, outgrid)