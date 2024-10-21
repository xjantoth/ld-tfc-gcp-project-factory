locals {
    _project_path = "../project-factory/data/projects"
    _projects = merge(
    {
      for f in try(fileset(local._project_path, "**/*.yaml"), []) :
      basename(trimsuffix(f, ".yaml")) => yamldecode(file("${local._project_path}/${f}"))
    }
  )

}
