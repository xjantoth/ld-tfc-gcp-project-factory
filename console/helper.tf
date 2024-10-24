resource "shoes" "this" {
   color = "pink"
   size  = "..."
   ...

   depends_on = [
       module.parents
   ]
}

