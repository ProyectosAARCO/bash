#! /bin/bash 

# Funcion para crear el nombre del archivo
create_name_file() {
    # Nombre del archivo
    local file=$1

    # Obtener la fecha del archivo
    fecha=$(stat -c "%y" "$file" | awk '{print $1}' | cut -d' ' -f1)
    anio=$(date -d "$fecha" "+%Y")
    mes=$(date -d "$fecha" "+%m")
    dia=$(date -d "$fecha" "+%d")
    hora=$(date -d "$fecha" "+%H")
    minuto=$(date -d "$fecha" "+%M")
    segundo=$(date -d "$fecha" "+%S")
    # Crear el nombre del archivo rar
    local nombre_archivo="gmm-emision@$anio-$mes-$dia-$hora-$minuto-$segundo.rar"
    echo $nombre_archivo
}

# Funcion para crear el archivo rar con la versión publicada y eliminar versión.
createRar() {
    # Ruta de la carpeta de publicaciones
    local ruta=$1

    # Crear el nombre del archivo rar
    local nombre_archivo=$(create_name_file $ruta)

    echo "Creando archivo rar: $nombre_archivo"

    # Crear el archivo rar
    rar a "$ruta/$nombre_archivo" "$ruta/index.html" "$ruta/vite.svg" "$ruta/assets"

    # Verificar que se creó el archivo rar correctamente
    if [ -f "$ruta/$nombre_archivo" ] && [ $(stat -c "%s" "$ruta/$nombre_archivo") -gt 0 ]; then
        # Eliminar los archivos y carpetas
        rm "$ruta/index.html"
        rm "$ruta/vite.svg"
        rm -r "$ruta/assets"
        echo "El archivo rar se creó correctamente: $nombre_archivo"
    else
        echo "Error: no se creó el archivo rar"
    fi
}

# Función para publicar en un entorno específico
publish() {
    local env=$1
    local dir=$2
    local command=$3

    echo "Publicando en el entorno $env..."
    echo "Directorio: $dir"
    echo "Comando: $command"

    # Ejecutar el comando de construcción
    eval $command

    # Verificar si el comando se ejecutó correctamente
    if [ $? -eq 0 ]; then
        createRar $dir
        echo "Construcción exitosa. Copiando archivos a $dir..."
        # Copiar archivos al directorio especificado
        cp -r build/* $dir
        echo "Publicación en $env completada."
    else
        echo "Error en la construcción. Publicación en $env fallida."
    fi
}

# Configuración de entornos
declare -A environments
environments["uat"]="/mnt/z npm run build:uat"
environments["dev"]="\\\\192.168.211.89\\Cotizamatico\\Publicaciones\\NuevoCotizamatico\\Web\\DEV\\gmm-emision npm run build:dev"
environments["local"]="\\\\192.168.211.89\\Cotizamatico\\Publicaciones\\NuevoCotizamatico\\Web\\LOCAL\\gmm-emision npm run build:local"
environments["prod"]="\\\\192.168.211.89\\Cotizamatico\\Publicaciones\\NuevoCotizamatico\\Web\\PROD\\gmm-emision npm run build"

# Configuración de comandos
declare -A commands
commands["uat"]="npm run build:uat"
commands["dev"]="npm run build:dev"
commands["local"]="npm run build:local"
commands["prod"]="npm run build:prod"

# Configuración de directorios
declare -A directories
directories["uat"]="/mnt/z"
directories["w1"]="/mnt/w1/gmm-emision"
directories["w2"]="/mnt/w2/gmm-emision"
# directories["uat"]="/mnt/z/UAT/gmm-emision"
# directories["sit"]="/mnt/z/SIT/gmm-emision"
directories["prod"]="/mnt/z/NEW/gmm-emision"
# directories["dev"]="\\\\192.168.211.89\\Cotizamatico\\Publicaciones\\NuevoCotizamatico\\Web\\DEV\\gmm-emision"
# directories["local"]="\\\\192.168.211.89\\Cotizamatico\\Publicaciones\\NuevoCotizamatico\\Web\\LOCAL\\gmm-emision"
# directories["prod"]="\\\\192.168.211.89\\Cotizamatico\\Publicaciones\\NuevoCotizamatico\\Web\\PROD\\gmm-emision"

# Verificar si se proporcionó un entorno
if [ -z "$1" ]; then
    echo "Uso: $0 {uat|dev|local|prod}"
    exit 1
fi

# Obtener la configuración del entorno
env_config=${environments[$1]}
if [ -z "$env_config" ]; then
    echo "Entorno no válido: $1"
    echo "Uso: $0 {uat|dev|local|prod}"
    exit 1
fi

# Separar el directorio y el comando
IFS=' ' read -r dir command <<< "$env_config"

# Publicar en el entorno especificado
publish $1 $dir "$command"