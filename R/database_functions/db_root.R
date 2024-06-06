# Find the database root path
# Written by June Skeeter March 2024

# Run from the root of your project folder to identify the proper path to the database for your project

library("yaml")

# Names of config files to search for
# Generic configuration option
# Not yet implemented but could be later
config_fn = '_config.yml'
user_paths = 'user_path_definitions.yml'
# Default matlab option, following current procedures
matlab_fn = 'biomet_database_default.m'

# Multiple possible configuration file names for now
# should be streamlined later
possible_config_files = c(user_paths,config_fn,matlab_fn)

# Subfolders to search for configuration file
roots = c('.','Matlab')


# Search environment variables for UBC_PC_Setup
# To be removed later once properly flushed out procedure is worked out
A <- 'UBC_PC_Setup'
B <- unname(Sys.getenv(names='True'))
pth <- setNames(lapply(A, function(x) grep(x, B, value = TRUE)), A)
if (!identical(unname(pth)[[1]], character(0))){
    roots = c(roots,pth)
}

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
        
get_config <- function(fn){
    config <- yaml.load_file(fn)
    return(config$RootDirs$Database)
    }


success = 0
for(file in possible_config_files){
    for(root in roots){
        config_file = file.path(root,file)
        if (file.exists(config_file)){
            db_root <- get_config(config_file)
            success = 1
            break
        }
    }
    if (success == 1) break
}

if (success  == 0){
    print('Default database path not identified!  Ensure you have the configuration setup properly')
    } else {
    db_ini = file.path(db_root[1],'Calculation_Procedures/TraceAnalysis_ini/')
    print(sprintf('Initialized db_root: %s',db_root))
}