# Find the database root path
# Written by June Skeeter March 2024

# Run from the root of your project folder to identify the proper path to the database for your project

library("yaml")

# Names of config files to search for
# Generic configuration option
# Not yet implemented but could be later
config_fn = '_config.yml'
# Default matlab option, following current procedures
matlab_fn = 'biomet_database_default.m'

# To find database_default from inside (the root) of a project folder
get_biomet_default <- function(fn){
    # Read .m file as "text"
    config <- paste(readLines(fn), collapse="\n")
    # Identify system, translate Matlab to Python, and evaluate
    config <- gsub('function x = biomet_database_default\n','',as.character(config))
    config <- gsub('%','#',as.character(config))
    config <- gsub('\\\\','/',as.character(config))
    config <- strsplit(config,"if ispc")[[1]]
    if (length(config)>1) {
       config <- config[2]
    }
    config <- strsplit(config,"elseif ismac")[[1]]
    if(.Platform$OS.type == "unix") {
        eval(parse(text=config[2]))
    } else {
        eval(parse(text=config[1]))
    }
    return(x)
}
        
get_config <- function(fn='_config.yml'){
    config <- yaml.load_file(fn)
    return(config$RootDirs$Database)
    }

{
# 1 Search for _config.yml in root of Project Folder
if (file.exists(config_fn)){
    db_root <- get_config(config_fn)
}
# 2 Search for matalab default in root of current folder
else if (file.exists(matlab_fn)) {
    db_root <- get_biomet_default(matlab_fn)
}
# 3 Search for Matlabl folder in root of project folder
else if (file.exists(file.path('Matlab/',matlab_fn))) {
    db_root <- get_biomet_default(file.path('Matlab/',matlab_fn))
}
# 4 Search environment variables for UBC_PC_Setup
# Repeat 1 & 2, prompt for input as last resort
else {
    A <- 'UBC_PC_Setup'
    B <- unname(Sys.getenv(names='True'))
    pth <- setNames(lapply(A, function(x) grep(x, B, value = TRUE)), A)
    if (!identical(unname(pth)[[1]], character(0))){
        if (file.exists(file.path(pth,config_fn))){
            db_root <- get_config(file.path(pth,config_fn))
        }else if (file.exists(file.path(pth,'PC_specific',matlab_fn))) {
            db_root <- get_biomet_default(file.path(pth,'PC_specific',matlab_fn))
        }
    }else{
        print('Default database path not identified!  Ensure you have the configuration setup properly')
    }
}
}

db_ini = file.path(db_root[1],'Calculation_Procedures/TraceAnalysis_ini/')

