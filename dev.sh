NAME=shims
DOCKER_IMAGE=quay.io/hallamlab/external_$NAME
# DOCKER_IMAGE=quay.io/hallamlab/$NAME
echo image: $DOCKER_IMAGE
echo ""

HERE=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

case $1 in
    --build|-b)
        # change the url in python if not txyliu
        # build the docker container locally *with the cog db* (see above)
        cd docker 
        docker build --build-arg CONDA_ENV=${NAME}_env -t $DOCKER_IMAGE .
    ;;
    --push|-p)
        # login and push image to quay.io, remember to change the python constants in src/
        # sudo docker login quay.io
	    docker push $DOCKER_IMAGE:latest
    ;;
    --sif)
        # test build singularity
        singularity build $NAME.sif docker-daemon://$DOCKER_IMAGE:latest
    ;;
    --run|-r)
        # test run docker image
            # --mount type=bind,source="$HERE/scratch",target="/ws" \
            # --mount type=bind,source="$HERE/scratch/res",target="/ref"\
            # --mount type=bind,source="$HERE/scratch/res/.ncbi",target="/.ncbi" \
            # --mount type=bind,source="$HERE/test",target="/ws" \
            # --mount type=bind,source="$HERE/test/checkm_db",target="/checkm_db" \
            # -e XDG_CACHE_HOME="/ws"\
            
        docker run -it --rm \
            --workdir="/ws" \
            -u $(id -u):$(id -g) \
            $DOCKER_IMAGE \
            /bin/bash 
    ;;
    -t)
        docker run -it --rm \
            --mount type=bind,source="$HERE/scratch",target="/ws"\
            --workdir="/ws" \
            -e MPLCONFIGDIR="/ws" \
            -u $(id -u):$(id -g) \
            $DOCKER_IMAGE \
            mintia check
            # /bin/bash 
    ;;
    *)
        echo "bad option"
        echo $1
    ;;
esac
