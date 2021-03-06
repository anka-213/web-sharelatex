ProjectEntityHandler = require "../Project/ProjectEntityHandler"
Errors = require "../../errors"
logger = require("logger-sharelatex")

module.exports =
	getDocument: (req, res, next = (error) ->) ->
		project_id = req.params.Project_id
		doc_id = req.params.doc_id
		logger.log doc_id:doc_id, project_id:project_id, "receiving get document request from api (docupdater)"
		ProjectEntityHandler.getDoc project_id, doc_id, (error, lines, version, rev) ->
			if error?
				logger.err err:error, doc_id:doc_id, project_id:project_id, "error finding element for getDocument"
				return next(error)
			res.type "json"
			res.send JSON.stringify {
				lines: lines
				version: version
			}
			req.session.destroy()

	setDocument: (req, res, next = (error) ->) ->
		project_id = req.params.Project_id
		doc_id = req.params.doc_id
		lines = req.body.lines
		version = req.body.version
		logger.log doc_id:doc_id, project_id:project_id, "receiving set document request from api (docupdater)"
		ProjectEntityHandler.updateDocLines project_id, doc_id, lines, version, (error) ->
			if error?
				logger.err err:error, doc_id:doc_id, project_id:project_id, "error finding element for getDocument"
				return next(error)
			res.send 200
			req.session.destroy()

		
		
