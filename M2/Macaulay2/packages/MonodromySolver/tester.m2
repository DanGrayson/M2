uninstallPackage "MonodromySolver"
restart
installPackage("MonodromySolver",FileName=>"../MonodromySolver.m2",
    RerunExamples=>true,RunExamples=>true,
    RemakeAllDocumentation=>true,MakeDocumentation=>true,
    IgnoreExampleErrors=>true)
help seedTest

viewHelp MonodromySolver

check MonodromySolver
