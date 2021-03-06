path = require('path')
ProjectUploadManager = require('../Uploads/ProjectUploadManager')
ProjectOptionsHandler = require("../Project/ProjectOptionsHandler")
TemplatesPublisher = require("./TemplatesPublisher")
settings = require('settings-sharelatex')
fs = require('fs')
request = require('request')
uuid = require('node-uuid')
logger = require('logger-sharelatex')


module.exports =
		
	createProjectFromZipTemplate: (req, res)->
		logger.log body:req.session.templateData, "creating project from zip"
		if !req.session.templateData?
			return res.redirect "/project"
			
		dumpPath = "#{settings.path.dumpFolder}/#{uuid.v4()}"
		writeStream = fs.createWriteStream(dumpPath)
		zipUrl = req.session.templateData.zipUrl
		if zipUrl.slice(0,12).indexOf("templates") == -1
			zipUrl = "#{settings.apis.web.url}#{zipUrl}"
		else
			zipUrl = "#{settings.apis.templates_api.url}#{zipUrl}"
		request(zipUrl).pipe(writeStream)
		writeStream.on 'close', ->
			ProjectUploadManager.createProjectFromZipArchive req.session.user._id, req.session.templateData.templateName, dumpPath, (err, project)->
				if err?
					logger.err err:err, zipUrl:zipUrl, "problem building project from zip"
					return res.send 500
				setCompiler project._id, req.session.templateData.compiler, ->
					fs.unlink dumpPath, ->
					delete req.session.templateData
					res.redirect "/project/#{project._id}"

	publishProject: (user_id, project_id, callback)->
		logger.log user_id:user_id, project_id:project_id, "receiving request to publish project as template"
		TemplatesPublisher.publish user_id, project_id, callback

	unPublishProject: (user_id, project_id, callback)->
		logger.log user_id:user_id, project_id:project_id, "receiving request to unpublish project as template"
		TemplatesPublisher.unpublish user_id, project_id, callback

	getTemplateDetails: (user_id, project_id, callback)->
		TemplatesPublisher.getTemplateDetails user_id, project_id, (err, details)->
			if err?
				logger.err err:err, user_id:user_id, project_id:project_id, "something went wrong getting template details"
			callback(err, details)


setCompiler = (project_id, compiler, callback)->
	if compiler?
		ProjectOptionsHandler.setCompiler project_id, compiler, callback
	else
		callback()
