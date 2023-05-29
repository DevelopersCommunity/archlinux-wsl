FROM archlinux:latest

COPY scripts/1-arch.sh ./1-arch.sh
RUN chmod +x ./1-arch.sh && ./1-arch.sh && rm ./1-arch.sh
