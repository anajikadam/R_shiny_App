library(shiny)

js <- "
$(document).ready(function(){
  $('#printPdf_CA').click(function () {
    domtoimage.toPng(document.getElementById('mainOrder_CA'))
      .then(function (blob) {
        var pdf = new jsPDF('l', 'pt', [$('#mainOrder_CA').width(), $('#mainOrder_CA').height()]);
        pdf.addImage(blob, 'PNG', 0, 0, $('#mainOrder_CA').width(), $('#mainOrder_CA').height());
        pdf.save('test.pdf');
        // that.options.api.optionsChanged(); what is that?
      });
  });
});
"

ui <- fluidPage(
  tags$head(
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.5.3/jspdf.min.js"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/dom-to-image/2.6.0/dom-to-image.min.js"),
    tags$script(js)
  ),
  br(),
  actionButton("printPdf_CA", "Print"),
  div(
    id = "mainOrder_CA",
    h3("Click on the button to print me")
  )
)

server <- function(input, output, session){
  
}

shinyApp(ui, server)