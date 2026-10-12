// Entrypoint for the local-only writing tool. Only built in development and
// test (see additionalEntrypoints in config/vite.json); never published.
import "bootstrap/dist/css/bootstrap.css"
// Lexxy does not list its stylesheets in its package exports.
import "../../../../node_modules/@37signals/lexxy/dist/stylesheets/lexxy.css"
import "./editor.css"

import "@hotwired/turbo-rails"
import "@37signals/lexxy"
import { Application } from "@hotwired/stimulus"
import { registerControllers } from "stimulus-vite-helpers"

const application = Application.start()
const controllers = import.meta.glob("./controllers/*_controller.js", { eager: true })
registerControllers(application, controllers)
