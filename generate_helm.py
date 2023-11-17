#!/usr/bin/env python

import oyaml


def main():
    yml = oyaml.safe_load(open("docker-compose.yml"))
    rm_services = ["postgres14", "postgres"]
    for svc in rm_services:
        yml["services"].pop(svc)
    for svc in yml["services"].values():
        for rm_svc in rm_services:
            if "depends_on" in svc and rm_svc in svc["depends_on"]:
                svc["depends_on"].remove(rm_svc)
    yml["services"]["enketo"]["ports"] = [8005]
    yml["services"]["enketo_redis_main"]["ports"] = [6379]
    yml["services"]["enketo_redis_cache"]["ports"] = [6380]
    yml["services"]["pyxform"]["ports"] = [80]
    yml["services"]["mail"]["ports"] = [25]
    yml["services"]["service"]["ports"] = [8383]
    yml["services"]["nginx"]["labels"] = {"kompose.service.type": "loadbalancer"}
    ghcr_services = ["service", "nginx", "enketo", "secrets"]
    for svc in ghcr_services:
        yml["services"][svc].pop("build")
        yml["services"][svc]["image"] = f"ghcr.io/caktus/central-{svc}"
    print(oyaml.dump(yml))


if __name__ == "__main__":
    main()
