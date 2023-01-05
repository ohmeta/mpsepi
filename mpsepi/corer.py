#!/usr/bin/env python

import argparse
import os
import subprocess
import sys
import textwrap
from io import StringIO

import pandas as pd

import mpsepi

MPSE_WF = [
    "mpse_import_all",
    "mpse_rarefy_all",
    "mpse_composition_all",
    "mpse_diversity_alpha_all",
    "mpse_diversity_beta_all",
    "mpse_diff_all",
    "all"
]


def run_snakemake(args, unknown, snakefile, workflow):
    conf = mpsepi.parse_yaml(args.config)

    cmd = [
        "snakemake",
        "--snakefile",
        snakefile,
        "--configfile",
        args.config
    ] + unknown

    if args.conda_create_envs_only:
        cmd += ["--use-conda", "--conda-create-envs-only"]
    else:
        cmd += [
            "--rerun-incomplete",
            "--keep-going",
            "--printshellcmds",
            "--reason",
            "--until",
            args.task
        ]

        if args.use_conda:
            cmd += ["--use-conda"]
            if args.conda_prefix is not None:
                cmd += ["--conda-prefix", args.conda_prefix]

        if args.list:
            cmd += ["--list"]
        elif args.run_local:
            cmd += ["--cores", str(args.cores)]
        elif args.run_remote:
            cmd += ["--profile", args.profile, "--local-cores", str(args.local_cores), "--jobs", str(args.jobs)]
        elif args.debug:
            cmd += ["--debug-dag", "--dry-run"]
        elif args.dry_run:
            cmd += ["--dry-run"]

    cmd_str = " ".join(cmd).strip()
    print("Running mpsepi %s:\n%s" % (workflow, cmd_str))

    env = os.environ.copy()
    proc = subprocess.Popen(
        cmd_str,
        shell=True,
        stdout=sys.stdout,
        stderr=sys.stderr,
        env=env,
    )
    proc.communicate()


def init(args, unknown):
    if args.workdir:
        project = mpsepi.mpseconfig(args.workdir)
        print(project.__str__())
        project.create_dirs()
        conf = project.get_config()

        for env_name in conf["envs"]:
            conf["envs"][env_name] = os.path.join(
                os.path.realpath(args.workdir), f"envs/{env_name}.yaml"
            )

        mpsepi.update_config(
            project.config_file, project.new_config_file, conf, remove=False
        )
    else:
        print("Please supply a workdir!")
        sys.exit(-1)


def mpse_wf(args, unknown):
    snakefile = os.path.join(os.path.dirname(__file__), "snakefiles/mpse_wf.smk")
    run_snakemake(args, unknown, snakefile, "mpse_wf")


def snakemake_summary(snakefile, configfile, task):
    cmd = [
        "snakemake",
        "--snakefile",
        snakefile,
        "--configfile",
        configfile,
        "--until",
        task,
        "--summary",
    ]
    cmd_out = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    summary = pd.read_csv(StringIO(cmd_out.stdout.read().decode()), sep="\t")
    return summary


def main():
    banner = """

 ▄▄       ▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄ 
▐░░▌     ▐░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
▐░▌░▌   ▐░▐░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌ ▀▀▀▀█░█▀▀▀▀ 
▐░▌▐░▌ ▐░▌▐░▌▐░▌       ▐░▌▐░▌          ▐░▌          ▐░▌       ▐░▌     ▐░▌     
▐░▌ ▐░▐░▌ ▐░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌     ▐░▌     
▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌     ▐░▌     
▐░▌   ▀   ▐░▌▐░█▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀      ▐░▌     
▐░▌       ▐░▌▐░▌                    ▐░▌▐░▌          ▐░▌               ▐░▌     
▐░▌       ▐░▌▐░▌           ▄▄▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌           ▄▄▄▄█░█▄▄▄▄ 
▐░▌       ▐░▌▐░▌          ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌          ▐░░░░░░░░░░░▌
 ▀         ▀  ▀            ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀            ▀▀▀▀▀▀▀▀▀▀▀ 
                                                                              


      Omics for All, Open Source for All

      Microbiome data process and visualization pipeline

"""

    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=textwrap.dedent(banner),
        prog="mpsepi",
    )
    parser.add_argument(
        "-v",
        "--version",
        action="store_true",
        default=False,
        help="print software version and exit",
    )

    common_parser = argparse.ArgumentParser(add_help=False)
    common_parser.add_argument(
        "-d",
        "--workdir",
        metavar="WORKDIR",
        type=str,
        default="./",
        help="project workdir",
    )

    run_parser = argparse.ArgumentParser(add_help=False)
    run_parser.add_argument(
        "--config",
        type=str,
        default="./config.yaml",
        help="config.yaml",
    )
    run_parser.add_argument(
        "--profile",
        type=str,
        default="./profiles/slurm",
        help="cluster profile name",
    )
    run_parser.add_argument(
        "--cores",
        type=int,
        default=32,
        help="all job cores, available on '--run-local'")
    run_parser.add_argument(
        "--local-cores",
        type=int,
        dest="local_cores",
        default=8,
        help="local job cores, available on '--run-remote'")
    run_parser.add_argument(
        "--jobs",
        type=int,
        default=80,
        help="cluster job numbers, available on '--run-remote'")
    run_parser.add_argument(
        "--list",
        default=False,
        action="store_true",
        help="list pipeline rules",
    )
    run_parser.add_argument(
        "--debug",
        default=False,
        action="store_true",
        help="debug pipeline",
    )
    run_parser.add_argument(
        "--dry-run",
        default=True,
        dest="dry_run",
        action="store_true",
        help="dry run pipeline",
    )
    run_parser.add_argument(
        "--run-local",
        default=False,
        action="store_true",
        help="run pipeline on local computer",
    )
    run_parser.add_argument(
        "--run-remote",
        default=False,
        action="store_true",
        help="run pipeline on remote cluster",
    )
    run_parser.add_argument(
        "--cluster-engine",
        default="slurm",
        choices=["slurm", "sge", "lsf", "pbs-torque"],
        help="cluster workflow manager engine, support slurm(sbatch) and sge(qsub)"
    )
    run_parser.add_argument("--wait", type=int, default=60, help="wait given seconds")
    run_parser.add_argument(
        "--use-conda",
        default=False,
        dest="use_conda",
        action="store_true",
        help="use conda environment",
    )
    run_parser.add_argument(
        "--conda-prefix",
        default="~/.conda/envs",
        dest="conda_prefix",
        help="conda environment prefix",
    )
    run_parser.add_argument(
        "--conda-create-envs-only",
        default=False,
        dest="conda_create_envs_only",
        action="store_true",
        help="conda create environments only",
    )

    subparsers = parser.add_subparsers(title="available subcommands", metavar="")
    parser_init = subparsers.add_parser(
        "init",
        formatter_class=mpsepi.custom_help_formatter,
        parents=[common_parser],
        prog="mpsepi init",
        help="init project",
    )
    parser_mpse_wf = subparsers.add_parser(
        "mpse_wf",
        formatter_class=mpsepi.custom_help_formatter,
        parents=[common_parser, run_parser],
        prog="mpsepi mpse_wf",
        help="microbiome data process and visualization pipeline",
    )

    parser_init.set_defaults(func=init)

    parser_mpse_wf.add_argument(
        "task",
        metavar="TASK",
        nargs="?",
        type=str,
        default="all",
        choices=MPSE_WF,
        help="pipeline end point. Allowed values are " + ", ".join(MPSE_WF),
    )
    parser_mpse_wf.set_defaults(func=mpse_wf)

    args, unknown = parser.parse_known_args()

    try:
        if args.version:
            print("mpsepi version %s" % mpsepi.__version__)
            sys.exit(0)
        args.func(args, unknown)
    except AttributeError as e:
        print(e)
        parser.print_help()


if __name__ == "__main__":
    main()